require 'active_record'
require 'json'

class Message
    attr_accessor :subject
    attr_accessor :content
    attr_accessor :writeitinstance
    attr_accessor :recipients
    attr_accessor :remote_uri
    attr_accessor :remote_id
    attr_accessor :author_name
    attr_accessor :author_email

    def push_to_api
        
        raise ArgumentError, 'No recipients, please add some first' unless self.recipients.any?
        
        data = {
            :author_name => self.author_name,
            :author_email => self.author_email,
            :subject => self.subject,
            :content => self.content,
            :writeitinstance => self.writeitinstance.url,
            :persons => self.recipients
        }
        authorization = 'ApiKey %{username}:%{api_key}' % {
            :username => self.writeitinstance.username,
            :api_key => self.writeitinstance.api_key,
        }
        url = self.writeitinstance.base_url + '/api/v1/message/'

        request = RestClient::Request.new(
            :method => :post,
            :url => url,
            :headers => {
                :accept => :json,
                :authorization => authorization,
                },
            :payload => data.to_json
            )
        request.processed_headers["Content-Type"] = 'application/json'
        response = request.execute
        data = JSON.parse(response.body)
        self.remote_id = data['id']
        self.remote_uri = data['resource_uri']


    end

end
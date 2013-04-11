require 'net/https'

module Chillout
  class PlainHttpClient
    MEDIA_TYPE = "application/vnd.chillout.v1+json"

    def post(path, data)
      http = Net::HTTP.new("api.chillout.io", 443)
      http.use_ssl = true
      request_spec = Net::HTTP::Post.new(path)
      request_spec.body = MultiJson.dump(data)
      request_spec.content_type = MEDIA_TYPE
      response = http.start do
        http.request(request_spec)
      end
      MultiJson.load(response.body)
    end
  end
end

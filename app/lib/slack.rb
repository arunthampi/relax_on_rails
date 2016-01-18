require 'uri'

class Slack
  def initialize(token)
    @token = token
  end

  def call(slack_api, method, params = {})
    params.merge!(token: URI.encode(@token))
    encoded_params = params.map { |k,v| "#{k}=#{URI.encode(v)}" }.join("&")

    url = "https://slack.com/api/#{slack_api}?#{encoded_params}"
    connection = Excon.new(url, connect_timeout: 360,
                         omit_default_port: true,
                         idempotent: true,
                         retry_limit: 6,
                         read_timeout: 360)
    response = connection.request(method: method)
    JSON.parse(response.body)
  end
end


require "ostruct"
require "net/http"
require "json"

class FlyCertificatesService
  BASE_URL = "https://api.machines.dev/v1"

  def initialize(app_name: ENV.fetch("FLY_APP_NAME", "slsh-me"), api_token: ENV["FLY_API_TOKEN"])
    @app_name = app_name
    @api_token = api_token
  end

  def add(hostname)
    post("/apps/#{@app_name}/certificates/acme", hostname: hostname)
  end

  def check(hostname)
    post("/apps/#{@app_name}/certificates/#{hostname}/check")
  end

  def delete(hostname)
    request(:delete, "/apps/#{@app_name}/certificates/#{hostname}")
  end

  def configured?
    @api_token.present?
  end

  private

  def post(path, body = nil)
    request(:post, path, body)
  end

  def request(method, path, body = nil)
    return OpenStruct.new(success?: false, error: "FLY_API_TOKEN not configured") unless configured?

    uri = URI("#{BASE_URL}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 15

    req = case method
          when :post   then Net::HTTP::Post.new(uri)
          when :delete then Net::HTTP::Delete.new(uri)
          else raise ArgumentError, "Unsupported method: #{method}"
          end

    req["Authorization"] = "Bearer #{@api_token}"
    req["Content-Type"] = "application/json"
    req.body = body.to_json if body

    response = http.request(req)

    OpenStruct.new(
      success?: response.code.to_i.between?(200, 299),
      status: response.code.to_i,
      body: response.body.present? ? JSON.parse(response.body) : nil
    )
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError => e
    OpenStruct.new(success?: false, error: e.message)
  rescue JSON::ParserError
    OpenStruct.new(success?: response.code.to_i.between?(200, 299), status: response.code.to_i, body: nil)
  end
end

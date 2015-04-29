class RestAgent
  require 'uri'
  require 'net/http'
  require 'logger'

  attr_reader :service_uri
  attr_accessor :headers
  
  $LOG = Logger.new('rubybvc-requests.log')

  def initialize(service_uri, headers: {}, username: nil, password: nil)
    @service_uri = URI(service_uri)
    @headers = {'Content-Type' => 'application/json', 'Accept' => 'application/json'}.merge(headers)
    @username = username
    @password = password
  end
  
  def get_request(uri_endpoint, query_params = {})
    uri = @service_uri + URI(uri_endpoint)
    uri.query = URI.encode_www_form(query_params) unless query_params.empty?
    req = Net::HTTP::Get.new(uri, @headers)
    return send_request(uri, req)
  end

  def post_request(uri_endpoint, post_body, headers: {})
    uri = @service_uri + URI(uri_endpoint)
    req = Net::HTTP::Post.new(uri, @headers.merge(headers))
    req.body = post_body.is_a?(String) ? post_body : post_body.to_json
    return send_request(uri, req)
  end
  
#  def patch_request(uri_endpoint, patch_body, headers: {})
#    uri = @service_uri + URI(uri_endpoint)
#    req = Net::HTTP::Patch.new(uri, @headers.merge(headers))
#    req.body = patch_body.to_json
#    return send_request(uri, req)
#  end

  def put_request(uri_endpoint, put_body, headers: {})
    uri = @service_uri + URI(uri_endpoint)
    req = Net::HTTP::Put.new(uri, @headers.merge(headers))
    req.body = put_body.to_json
    return send_request(uri, req)
  end

  def delete_request(uri_endpoint)
    uri = @service_uri + URI(uri_endpoint)
    req = Net::HTTP::Delete.new(uri, @headers)
    return send_request(uri, req)
  end

  private

  def send_request(uri, request)
    request.basic_auth(@username, @password) unless @username.nil? || @username.empty?
    begin
      $LOG.info request.to_yaml
      response =  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
      end
      $LOG.info response.to_yaml
      # catch html responses
      return response
    rescue Net::HTTPHeaderSyntaxError, Net::HTTPBadResponse => e
      #logger.error "Error connecting to #{@service_uri}: #{e.message}"
      return nil
    end
  end

end
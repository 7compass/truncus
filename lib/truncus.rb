require 'truncus/version'
require 'json'
require 'uri'
require 'net/http'


module Truncus
  class Client
    attr_accessor :host, :port

    def initialize(options = {})
      self.host = options[:host] || ENV['TRUNCT_HOST'] || 'trunc.us'
      self.port = options[:port] || ENV['TRUNCT_PORT'] || 443

      @http ||= Net::HTTP.new(host, port)
      @http.use_ssl = use_ssl?
      @http.verify_mode = options[:ssl_verify_mode] if options[:ssl_verify_mode]
    end


    # Convenience for instantiating a Client and retrieving a shortened url
    def self.expand_token(token)
      new.expand_token(token)
    end


    # Convenience for instantiating a Client, shortening a url,
    # and returning the shortened token
    def self.get_token(url)
      new.get_token(url)
    end


    # Convenience for instantiating a Client, shortening a url,
    # and returning it as a full url to the shortened version.
    def self.get_url(url)
      new.get_url(url)
    end


    def get_url(url)
      token = get_token(url)
      "http#{'s' if use_ssl?}://#{host}/#{token}"
    end


    # Shortens a URL, returns the shortened token
    def get_token(url)
      req      = Net::HTTP::Post.new('/', initheader = {'Content-Type' => 'application/json'})
      req.body = {url: url, format: 'json'}.to_json

      res = @http.request(req)
      data = JSON::parse(res.body)
      data['trunct']['token']
    end


    # Expand a token: returns the original URL
    def expand_token(token)
      url = URI.parse("http#{'s' if use_ssl?}://#{host}/#{token}.json")
      req = Net::HTTP::Get.new(url.path)
      res = @http.request(req)
      data = JSON::parse(res.body)
      data['trunct']['url']
    end


    # Is this client configured to use ssl/tls?
    def use_ssl?
      port.to_i == 443
    end
  end
end

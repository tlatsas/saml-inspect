require 'sinatra/base'
require 'zlib'
require 'base64'
require 'uri'
require 'cgi'


module Sinatra
  module SamlInspectHelpers
    def parse_request_data(data)
      uri = URI.parse(data)

      if uri.nil?
        query_string = CGI.parse(data)
      else
        query_string = CGI.parse(uri.query)
      end

      parsed_data = {}

      parsed_data[:saml_request]  = parse_saml query_string.fetch 'SAMLRequest', nil
      parsed_data[:saml_response] = parse_saml query_string.fetch 'SAMLResponse', nil
      parsed_data[:query_params] = query_string.reject { |k, v| ['SAMLRequest', 'SAMLResponse'].include? k }
      parsed_data[:query_params] = parsed_data[:query_params].each { |k, v| parsed_data[:query_params][k] = v.first }

      parsed_data
    end

    def parse_saml(saml, unescape=false)
      return nil if saml.nil?

      saml = saml.first

      unescaped = unescape ? CGI.unescape(saml) : saml
      decoded = Base64.decode64(unescaped)
      xml = Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(decoded)

      CGI.unescape(xml)
    end

    def h(text)
     Rack::Utils.escape_html(text)
    end
  end

  helpers SamlInspectHelpers
end


class SamlInspect < Sinatra::Base
  helpers Sinatra::SamlInspectHelpers

  set :views, "./views"

  get '/' do
    erb :new, :layout => :base
  end

  post '/' do
    data = params[:post][:saml]
    @parsed_data = parse_request_data data
    erb :inspection, :layout => :base
  end

  run! if app_file == $0
end

# vim: ai et ts=2 sw=2 sts=2

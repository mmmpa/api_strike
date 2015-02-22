require 'active_support/core_ext'

class Striker
  class << self
    def call(*args)
      new(*args)
    end
  end


  def initialize(config)
    @url = config[:config][:url]
    @method = config[:config][:http_method]
    @params = config[:params] && config[:params].each_with_object({}) do |(key, value), hash|
      if match_result = key.match(/(.+)_in_path$/)
        @url.gsub!(':' + match_result[1], value.gsub('/', ''))
      else
        hash[key] = value
      end
    end
    @format = config[:format]
  end


  def value_in_path

  end


  def response
    @response ||= RestClient.send(@method, @url, {params: @params})
  rescue => e
    @response = e.response
  end


  def parsed_responce
    case @format
      when :json
        JSON.parse(response.body)
      when :xml
        Hash.from_xml(response.body)
      else
        response.body
    end
  end


  def parse
    {
      status_code: response.code,
      content: parsed_responce,
      source: response.body.force_encoding('utf-8').gsub(',', ",\n")
    }
  rescue
    {content: response}
  end
end
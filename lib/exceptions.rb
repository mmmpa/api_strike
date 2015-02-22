module Exceptions
  class ApiStrikeError < StandardError
    def initialize(record = nil)
      @record = record
      super
    end


    def for_render
      {
        json: {message: 'error'},
        status: 500
      }
    end
  end

  module ApiStrike
    # config/settings/exception_config.yml
    # Need ActiveRecord::Error, has_error: true

    # for each class
    def self.for_exception(name, config)
      error_text = config[:has_error] ? ', errors: @record.errors' : nil
      %{
        class #{name.to_s.camelize} < ApiStrikeError
          def for_render
            {
              json: {message: '#{config[:message]}'#{error_text}},
              status: #{config[:status_code]}
            }
          end
        end
      }
    end


    # for nested class (into module)
    def self.to_string(name, config)
      if config.message
        for_exception(name, config)
      else
        %{
          module #{name.to_s.camelize}
            #{analise(config)}
          end
        }
      end
    end

    def self.analise(hash)
      hash.each_pair.each_with_object('') do |(name, config), string|
        string << to_string(name, config)
      end
    end

    # defining
    class_eval(analise(Settings.exception_config))
  end
end
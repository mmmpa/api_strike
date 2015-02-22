require 'rest_client'

class StrikeController < ApplicationController
  def show
    @facades = [
      StrikeForm.(:animemap, Settings.host.animemap),
      StrikeForm.(:hatena_haiku, Settings.host.hatena_haiku)
    ]
  end


  def strike
    @facade = LayoutMan.(Striker.(strike_params).parse, strike_params[:config][:title])
  end


  private
  def strike_params
    {
      config: ApiCoordination.(module_name, Settings.host[module_name]).detail(api_name),
      format: Settings.host[module_name].format,
      params: params[module_name]
    }
  end


  def module_name
    params[:api][:module_name]
  end


  def api_name
    params[:api][:api_name]
  end
end

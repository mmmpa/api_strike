class ApiCoordination
  using SlashTrimmer

  class << self
    def call(*args)
      new(*args)
    end
  end


  def initialize(module_name, config)
    @module_name = module_name
    @host = config[:host].trim_slash
    @api_hash = config[:api].deep_dup
    @format = config[:format]
  end


  def list
    @api_hash.each_pair.each_with_object([]) do |(key, value), result|
      result.push(parse(key, value))
    end
  end


  def detail(api_name)
    parse(api_name, @api_hash[api_name.to_s] || @api_hash[api_name.to_sym])
  end


  def parse(api_name, config)
    {
      module_name: @module_name,
      title: config[:title],
      api_name: api_name.to_s,
      url: @host + config[:uri].add_and_trim_slash,
      http_method: config[:http_method],
      param: config[:param] && ApiParamCoordination.(config[:param], @module_name).converted
    }.compact
  end
end


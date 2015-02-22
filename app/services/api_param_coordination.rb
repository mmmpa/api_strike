class ApiParamCoordination
  class << self
    def call(*args)
      new(*args)
    end
  end


  def initialize(params_array, base_name = '')
    @params_array = params_array.deep_dup
    @base_name = base_name
  end


  def converted
    convert_each_config(@params_array, @base_name)
  end


  def arralize(array)
    if array.is_a?(Array)
      array
    else
      [array]
    end.deep_dup
  end


  def convert_each_config (configs, base_name = nil)
    configs.collect do |dat|
      hash = dat.is_a?(Hash) ? dat : dat.to_h
      key = hash.keys.first
      value = hash.values.first
      if value.is_a?(Array)
        convert_each_config(value, arralize(base_name) + [key])
      else
        to_build_config(hash, base_name)
      end
    end.flatten
  end


  def to_build_config(config, base_name = nil)
    config.each_pair.each_with_object({}) do |(key, value), result|
      if value.respond_to?(:to_h)
        result.merge!(to_detail(value.to_h))
      else
        result.merge!(to_detail({type: value}))
      end.merge!({
          title: key.to_s,
          name: to_name([base_name, key.to_s + pathize(result.delete(:in_path))])
        })
    end
  end


  def pathize(bool)
    bool ? '_in_path' : ''
  end


  def to_detail(hash)
    {
      helper: to_helper(hash[:type]),
      in_path: hash[:type] == :path,
      title: hash[:title] && hash[:title].to_s,
      options: {
        value: hash[:value],
        choices: hash[:choices],
        options: hash[:options]
      }.compact
    }.compact
  end


  def to_helper(name)
    case name.to_s
      when 'text', 'number'
        :text_field
      when 'radio'
        :radio_buttons
      when 'checkbox'
        :check_boxes
      when 'select'
        :select
      when 'textarea'
        :textarea
      when 'password'
        :password
      when 'path'
        :text_field
      else
        :none
    end
  end


  def to_name(array)
    arralized = arralize(array).flatten.compact

    arralized.shift.to_s + arralized.collect do |name|
      "[#{name}]"
    end.join
  end
end
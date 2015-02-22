class StrikeForm
  class << self
    def call(*args)
      new(*args)
    end
  end


  def initialize(name, dat)
    @name = name
    @host = dat.host
    @api_list = dat.api
    @dat = dat
  end


  def name
    @name
  end


  def host
    @host
  end


  def list
    ApiCoordination.(@name, @dat).list
  end


  def render_start(dat, key = [])
    case
      when dat.is_a?(Array)
        render_array(dat, key)
      when dat.is_a?(Hash)
        render_hash(dat, key)
      else
        render_text(dat, key)
    end.html_safe
  end


  def render_hash(dat, key = [])
    body = dat.each_pair.each_with_object([]) do |(form_key, value), array|
      array.push "<tr><th>#{form_key}</th><td>#{render_start(value, form_key)}</td></tr>"
    end.join

    %{<h1 class="text-green">hash</h1><table>#{body}</table>}
  end


  def render_array(dat, key = [])
    body = dat.collect(&method(:render_start)).collect do |inner|
      "<li>#{inner}</li>"
    end.join

    %{<h1 class="text-green">hash</h1>array</h1><ul>#{body}</ul>}
  end


  def render_text(dat, key = [])
    "<div>#{dat}</div>"
  end

end
class LayoutMan
  class << self
    def call(*args)
      new(*args)
    end
  end


  def initialize(dat, title = '')
    @dat = dat
    @title = title
  end


  def render
    render_start(@dat)
  end


  def render_start(dat)
    case
      when dat.is_a?(Array)
        render_array(dat)
      when dat.is_a?(Hash)
        render_hash(dat)
      else
        render_text(dat)
    end.html_safe
  end


  def render_hash(dat)
    body = dat.each_pair.each_with_object([]) do |(key, value), array|
      array.push %{<tr><th class="text-righting bold small">#{key}</th><td>#{render_start(value)}</td></tr>}
    end.join

    %{<h1 class="bold text-green">Hash</h1><div class="table-wrapper border-silver"><table class="top small-padding border-silver horizontal-border">#{body}</table></div>}
  end


  def render_array(dat)
    body = dat.collect(&method(:render_start)).collect do |inner|
      %{<li class="sq big-margin-tb">#{inner}</li>}
    end.join

    %{<h1 class="bold text-green">Array</h1><ul>#{body}</ul>}
  end


  def render_text(dat)
    %{<div class="break">#{ERB::Util.html_escape(dat).gsub("\n", '<br>')}</div>}
  end

  def title
    @title || ''
  end
end
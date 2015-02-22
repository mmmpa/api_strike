module StrikeHelper
  def parse_to_html(hash, form)
    input = case hash[:helper]
              when :text_field
                hash[:options].merge!({
                    class: ['p100']
                  })
                form.text_field(nil, name: hash[:name], id: nil, ** hash[:options])
              when :radio_buttons
                form.radio_buttons(nil, hash[:options].merge(name: hash[:name]), hash[:options][:choices].zip(hash[:options][:choices]))
              else
            end
    %{<tr><th class="p50 text-righting bold">#{hash[:title]}</th><td class="p50">#{input}</td></tr>}.html_safe
  end
end

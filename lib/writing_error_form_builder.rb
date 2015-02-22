module ::Arralizer
  refine Object do
    def arralize
      if self.is_a?(Array)
        delf
      else
        if self.is_a?(NilClass)
          []
        else
          [self]
        end
      end
    end
  end
end

module WritingErrorFormBuilder
  class Builder < ::ActionView::Helpers::FormBuilder
    using ::Arralizer


    def initialize(object_name, object, template, options)
      default_tag(options[:builder_tag])
      super
    end


    def preset_tag

    end


    def default_tag(tags)
      @tags = tags || preset_tag || {}

      @tags[:wrapper] ||= {tag: :div, class: 'normal-field'}
      @tags[:invalid_wrapper] ||= {tag: :div, class: 'invalid-field'}
      @tags[:error_parent] ||= {tag: :ul, class: 'errors'}
      @tags[:error] ||= {tag: :li, class: 'error'}

      @tags.each_pair do |key, value|
        @tags[key.to_sym] = normalize_tag(value)
      end
    end


    def normalize_tag(src)
      tag = src.dup
      case
        when tag.is_a?(Hash)
          unless tag[:class].is_a?(Array)
            tag[:class] = tag[:class].arralize
          end
        else
          tag = {
              tag: tag,
              class: []
          }
      end
      tag
    end


    def for_attribute(hash, attribute)
      new_hash = hash.deep_dup
      new_hash[:class].push(attribute)
      new_hash
    end


    def pick_error(attribute)
      return nil if @object.nil? || !(messages = @object.errors.messages[attribute]).present?

      children = messages.collect do |message|
        wrap(for_attribute(@tags[:error], attribute), message)
      end.join

      wrap(for_attribute(@tags[:error_parent], attribute), children).html_safe
    end


    def wrap(tag, wrapped)
      return wrapped unless tag.present?

      tag = {tag: tag} unless tag.is_a?(Hash)
      head_tag = begin
        attrs = {}
        if (classes = tag[:class]).present?
          attrs[:class] = if classes.is_a?(Array)
                            classes.join(' ')
                          else
                            classes
                          end
        end

        if options[:id]
          tag[:class] =options[:id]
        end

        if attrs.empty?
          %{<#{tag[:tag]}>}
        else
          %{<#{tag[:tag]} #{attrs.collect do |value|
            %{#{value.first}="#{value.last}"}
          end.join(' ')}>}
        end
      end

      %{#{head_tag}#{wrapped}</#{tag[:tag]}>}
    end


    (field_helpers - [:check_box, :radio_button, :fields_for, :hidden_field, :label]).each do |selector|
      force = case selector
                when :label
                  true
                else
                  false
              end
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{selector}(attribute, options = {})
          wrap_field(attribute, options) do
            super
          end
        end
      RUBY_EVAL
    end


    def label(attribute, options = {})
      wrap_field(attribute, options.merge(no_errors: true)) do
        super
      end
    end


    def wrap_field(attribute, options={})
      error_html = pick_error(attribute)

      no_errors = options.delete(:no_errors)
      no_wrap = options.delete(:no_wrap)

      if error_html.present?
        if no_errors
          yield
        else
          yield + error_html
        end
      else
        if no_wrap
          yield
        else
          wrap(@tags[:wrapper], yield)
        end
      end.html_safe
    end


    def around_proc(label_text)
      suf = wrap({tag: :span, class: :label}, label_text)
      input = wrap({tag: :span, class: :input}, '#{tag}')
      result = wrap(:label, "#{input}#{suf}")
      class_eval <<-REVAL
    ->(tag) {
          %{#{result}}.html_safe
    }
      REVAL
    end


    def check_box(attribute, options = {}, label_and_value = ['1', '1'], unchecked_value = "0")
      wrap_field(attribute, options) do
        if label_and_value.is_a?(Array)
          @template.check_box(@object_name, attribute,
              objectify_options(options.merge(around: around_proc(label_and_value.first))),
              label_and_value.last, unchecked_value)
        else
          super
        end
      end
    end


    def radio_button(attribute, label_and_value, options = {})
      wrap_field(attribute, options) do
        if label_and_value.is_a?(Array)
          @template.radio_button(@object_name, attribute, label_and_value.last,
              objectify_options(options.merge(around: around_proc(label_and_value.first))))
        else
          super
        end
      end
    end


    def select(attribute, choices = nil, options = {}, html_options = {}, &block)
      wrap_field(attribute, options) do
        super
      end
    end


    def check_boxes(attribute, options = {}, labels_and_values = [['', '1']], parent_tag: {tag: :ul, class: 'check-boxes'}, children_tag: {tag: :li, class: 'check-boxes-child'})
      wrap_field(attribute, options.merge(no_wrap: true)) do
        wrap(parent_tag,
            labels_and_values.collect do |label_and_value|
              wrap(children_tag, check_box(attribute, options.merge(multiple: true, no_errors: true), label_and_value, nil))
            end.join).html_safe
      end
    end


    def radio_buttons(attribute, options = {}, labels_and_values = [['', '1']], parent_tag: {tag: :ul, class: 'radio-buttons'}, children_tag: {tag: :li, class: 'radio-buttons-child'})
      wrap_field(attribute, options.merge(no_wrap: true)) do
        wrap(parent_tag,
            labels_and_values.collect do |label_and_value|
              wrap(children_tag, radio_button(attribute, label_and_value, options.merge(no_errors: true)))
            end.join).html_safe
      end
    end

  end

  module ::ActionView
    module Helpers
      module ActiveModelInstanceTag
        def content_tag(tag_name, single_or_multiple_records, prefix = nil, options = nil, &block)
          supered = if around = options.try(:[], 'around')
                      options.delete('around')
                      around.call(super)
                    else
                      super
                    end

          error_wrapping(supered)
        end


        def tag(type, options, *)
          supered = if around = options.try(:[], 'around')
                      options.delete('around')
                      around.call(super)
                    else
                      super
                    end

          tag_generate_errors?(options) ? error_wrapping(supered) : supered
        end
      end
    end
  end
end

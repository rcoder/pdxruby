module Rubaidh #:nodoc:
  module FormHelper
    
    # def self.included(base)
    #   base.alias_method_chain :fields_for, :fieldset
    # end
    # 
    # # Behaves just like the regular +fields_for+ with a little extra magic
    # # juju in that it creates a fieldset around the fields inside.
    # def fields_for_with_fieldset(object_name, *args, &block)
    #   options = args.last.is_a?(Hash) ? args.pop : {}
    #   object  = args.first
    #   legend = options.delete(:legend) || object_name.to_s.humanize
    #   concat tag('fieldset', options, true), block.binding
    #   concat "<legend>#{legend}</legend>", block.binding
    #   fields_for_without_fieldset(object_name, object, options.merge(:builder => FormBuilder), &block)
    #   concat "</fieldset>", block.binding
    # end

    def label_for(object_name, method, options = {})
      ActionView::Helpers::InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_label_tag(options)
    end

    def label_tag(name, text, options = {})
      content_tag('label', text, { 'for' => name }.merge(options.stringify_keys))
    end

    def fieldset(options, builder, &block)
      legend = options.delete(:legend)
      concat tag('fieldset', options, true), block.binding
      concat "<legend>#{legend}</legend>", block.binding unless legend.blank?
      block.call(builder)
      concat "</fieldset>", block.binding
    end
    
    def grouped_collection_select(object_name, method, collection, group_method, group_label_method, value_method, text_method, options = {}, html_options = {})
      ActionView::Helpers::InstanceTag.new(object_name, method, self, nil, options.delete(:object)).to_grouped_collection_select_tag(collection, group_method, group_label_method, value_method, text_method, options, html_options)
    end
  end

  module InstanceTag #:nodoc:
    def to_label_tag(options = {})
      options = options.stringify_keys
      add_default_name_and_id(options)
      options.delete('name')
      options['for'] = options.delete('id')

      text = options.delete('label') || @method_name.humanize
      text += "\n" + content_tag('span', '(required)', :class => :required) if options.delete('required')
      description = options.delete('description')

      label = content_tag 'label', text, options

      unless description.blank?
        label += content_tag('p', description, {})
      end

      label
    end
    
    def to_grouped_collection_select_tag(collection, group_method, group_label_method, value_method, text_method, options, html_options)
      html_options = html_options.stringify_keys
      add_default_name_and_id(html_options)
      value = value(object)
      content_tag(
        "select",
        add_options(
          option_groups_from_collection_for_select(
            collection, group_method, group_label_method,
            value_method, text_method, value),
          options, value),
        html_options
      )
    end
  end

  module FormBuilderMethods #:nodoc:
    def label_for(method, options = {})
      @template.label_for(@object_name, method, options.merge(:object => @object))
    end

    # Implement a collection select for groups of options.  See
    # +options_from_collection_for_select+ for more information, but it's more
    # or less the same as +collection_select+.
    def grouped_collection_select(method, collection, group_method, group_label_method, value_method, text_method, options = {}, html_options = {})
      @template.grouped_collection_select(@object_name, method, collection, group_method, group_label_method, value_method, text_method, options.merge(:object => @object), html_options)
    end
  end

  class FormBuilder < ActionView::Helpers::FormBuilder #:nodoc:
    (ActionView::Helpers::FormHelper.instance_methods - %w(label_for hidden_field check_box radio_button form_for fields_for) + %w(datetime_select date_select)).each do |selector|
      src = <<-end_src
        def #{selector}(method, options = {})
          label_options = label_options_from_options(options)
          label_for(method, label_options) + "\n" + super
        end
      end_src
      class_eval src, __FILE__, __LINE__
    end

    def select(method, choices, options = {}, html_options = {})
      label_options = label_options_from_options(options)
      label_for(method, label_options) + "\n" + super
    end

    def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
      label_options = label_options_from_options(options)
      label_method = method.to_s.gsub /_ids$/, 's'

      # Generate the correct name for HABTM relations and multi-select boxes.
      html_options[:name] = "#{object_name}[#{method}][]" if html_options[:multiple]

      label_for(label_method, label_options) + "\n" + super
    end

    def grouped_collection_select(method, collection, group_method, group_label_method, value_method, text_method, options = {}, html_options = {})
      label_options = label_options_from_options(options)
      label_method = method.to_s.gsub /_ids$/, 's'

      # Generate the correct name for HABTM relations and multi-select boxes.
      html_options[:name] = "#{object_name}[#{method}][]" if html_options[:multiple]

      label_for(label_method, label_options) + "\n" + super
    end

    def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
      label_options = label_options_from_options(options)
      super + "\n" + label_for(method, label_options)
    end

    def radio_button(method, tag_value, options = {})
      label_options = label_options_from_options(options)
      super + "\n" + label_for(method, label_options)
    end

    def fields_for(object_name, object, builder = self.class, &proc)
      @template.fields_for(object_name, object, builder, &proc)
    end

    def fieldset(options = {}, builder = self, &block)
      @template.fieldset(options, builder, &block)
    end
    
    private
    def label_options_from_options(options)
      label_options = options.dup
      
      # Remove the options from the main field which apply solely to the 
      # label.
      [:label, :description, :required].each do |v|
        options.delete(v)
      end
      
      # Tidy up the label options so they only have what's required.
      label_options.reject do |k, v|
        ![:id, :label, :description, :required].include?(k)
      end
    end
  end
end
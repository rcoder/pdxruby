require 'rubaidh/form_helper'

ActionView::Base.send                 :include, Rubaidh::FormHelper
ActionView::Helpers::InstanceTag.send :include, Rubaidh::InstanceTag
ActionView::Helpers::FormBuilder.send :include, Rubaidh::FormBuilderMethods

# And set as the default form builder.
ActionView::Base.default_form_builder = Rubaidh::FormBuilder
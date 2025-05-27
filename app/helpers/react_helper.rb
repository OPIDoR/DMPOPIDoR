# frozen_string_literal: true

# React helper
module ReactHelper
  def react(component_name, props: {}, **args)
    content_tag(:div, '', data: {
                  controller: 'react',
                  react_component_value: component_name,
                  react_props_value: props
                }, **args)
  end
end

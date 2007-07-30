module Streamlined::DeprecatedUIClassMethods
  def deprecated_class_methods
    @deprecated_class_methods ||= Set.new([
      :user_columns,
      :custom_columns_group,
      :pagination,
      :table_row_buttons,
      :quick_delete_button,
      :quick_edit_button,
      :table_filter,
      :read_only,
      :new_submit_button,
      :edit_submit_button,
      :mark_required_fields,
      :header_partials,
      :footer_partials,
      :style_classes,
      :default_order_options,
      :edit_columns,
      :list_columns,
      :override_columns,
      :style_class_for,
      :exporters
    ])
  end
  def method_missing(method, *args)
    super(method, *args) unless deprecated_class_methods.member?(method)
    class_name = self.name.to_s.gsub(/ui$/i, '')
    ui = Streamlined.ui_for(class_name)
    ui.send(method, *args)
  end
end

class Streamlined::UI
  class <<self
    def inherited(derived)
      derived.class_eval { extend Streamlined::DeprecatedUIClassMethods }
    end
  end
end


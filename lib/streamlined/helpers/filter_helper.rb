module Streamlined::Helpers::FilterHelper
  attr_with_default(:advanced_filtering) {false}
  
  # return the columns to be used for Advanced Filter
  def advanced_filter_columns
    filter_columns = Hash.new

    model_ui.list_columns.each do |column|
      if column.is_a?(Streamlined::Column::ActiveRecord)
        filter_columns[column.human_name] = column.name 
      elsif column.is_a?(Streamlined::Column::Association)
        association_name = column.name
        names = %w{name title}
        no_name_yet = true
        names.each do |name|
          if no_name_yet && model.reflect_on_association(association_name).klass.column_names.index(name) 
            filter_columns[Inflector.humanize(association_name.to_s) + " (#{name})"] = "rel::" + association_name.to_s + "::" + "#{name}"
            no_name_yet = false
          end
        end    
      end  
    end
    filter_columns.sort 
  end
  
end
module Streamlined::Helpers::FilterHelper
  attr_with_default(:advanced_filtering) {false}
  
  # return the columns to be used for Filter By Value
  def filter_by_value_columns
    filter_columns = Hash.new

    model_ui.list_columns.each do |column|
      if database_column?(model, column, column.name)
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
  
  # Used for filter by value.  Only allow filtering on real db columns since we have to 
  # generate a db query
  def database_column?(model, column, column_name)
    # exclude calculated columns from the <class>UI
    unless column.nil?
      return false if column.is_a?(Streamlined::Column::Addition)
    end  

    # return true if a real db column.  exclude columns defined in the model.
    db_columns = model.columns.collect {|c| c.name}
    !db_columns.index(column_name).nil?
  end
end
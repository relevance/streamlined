class Streamlined::Context::RequestContext
  attr_accessor :filter, :page, :sort_order, :sort_column, :counter, :per_page
  include HashInit

  DELEGATES = [:sort_order, 
               :sort_column, 
               :filter,
               :filter?, 
               :order?, 
               :sort_ascending?, 
               :sort_column?, 
               :active_record_order_option, 
               {:to=>:streamlined_request_context}].freeze


  def filter?
    !self.filter.blank?
  end

  def order?
    !self.sort_column.blank?
  end
  
  def sort_ascending?
    self.sort_order != 'DESC' 
  end
  
  def sort_order
    @sort_order || 'ASC'
  end
  
  def sort_column?(column)
    column.name.to_s == sort_column
  end
  
  def active_record_order_option
    if sort_column && sort_order
      {:order => [sort_column, sort_order].map{|x| x.tr(" ", "_")}.join(" ")}
    else
      {}
    end
  end
  
end
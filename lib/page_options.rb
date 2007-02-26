# # Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com
#
# Used to monitor the Streamlined hidden form that controls sorting, filtering and pagination of the list views.

require 'pp'

class PageOptions
  attr_accessor :filter, :page, :sort_order, :sort_column, :counter, :per_page
  include HashInit


  def filter?
    !self.filter.blank?
  end

  def order?
    !self.sort_column.blank?
  end
  
  def ascending?
    self.sort_order != 'DESC' 
  end
  
  def sort_order
    @sort_order || 'ASC'
  end
  
  def active_record_order_option
    if self.sort_column && self.sort_order
      {:order => [self.sort_column, self.sort_order].map{|x| x.tr(" ", "_")}.join(" ")}
    else
      {}
    end
  end
  
end
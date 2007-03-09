module Streamlined; end
module Streamlined; module Helpers; end; end
module Streamlined; module Helpers; module Degradable; end; end; end
module Streamlined::Helpers::Degradable::LinkHelper
  def link_to_new_model
    link_to(image_tag('streamlined/add_16.png', 
        {:alt => "New #{@model_name}", :title => "New #{@model_name}", :border => '0'}),          
        :action => 'new')
  end

  def link_to_show_model(item)
    link_to(image_tag('streamlined/search_16.png', 
        {:alt => "Show #{@model_name}", :title => "Show #{@model_name}", :border => '0'}),          
        :action => 'show', :id=>item)
  end

  def text_link_to_edit_model(item)
    link_to(h(item.send(column.name)),url_for(:action => 'edit', :id=>item))
  end

  def link_to_edit_model(item)
    link_to(image_tag('streamlined/edit_16.png', 
        {:alt => "Edit #{@model_name}", :title => "Edit #{@model_name}", :border => '0'}),          
        :action => 'edit', :id=>item)
  end
  
  # TODO: delete confirm with no JavaScript
  
  # TODO: incomplete and needs refactoring common code with other LinkHelpers
end

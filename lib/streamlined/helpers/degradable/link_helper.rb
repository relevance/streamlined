module Streamlined; end
module Streamlined; module Helpers; end; end
module Streamlined; module Helpers; module Degradable; end; end; end
module Streamlined::Helpers::Degradable::LinkHelper
  def link_to_new_model
    link_to(image_tag('streamlined/add_16.png', 
        {:alt => "New #{@model_name}", :title => "New #{@model_name}", :border => '0'}),          
        url_for(:action => 'new'))
  end
  
  # TODO: incomplete and needs refactoring common code with other LinkHelpers
end

module Streamlined::Controller::Tags
  # TODO: tag code currently pollutes other modules. Can it all be gathered here?
  def add_tags
    if Object.const_defined?(:Tag) && params[:new_tags]
      item = model.find(params[:id])
      tags = params[:new_tags].split(' ')
      @new_tags = []
      tags.each do |tag| 
        unless Tag.find_by_name(tag)
          @new_tags << Tag.create(:name => tag)
        end  
      end
      render :update do |page|
        page['tags_form'].replace_html :partial => 'shared/tags', :locals => {:item => item}
      end
    end
  end
end
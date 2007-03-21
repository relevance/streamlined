module Streamlined::Controller::SmartColumns
  def columns
    render(:partial => "columns")
  end

  def reset_columns
    pref = current_user.preferences
    pref.page_columns ||= {}
    current_user.preferences.page_columns.delete( controller_name.to_sym )
    current_user.preferences.save
    current_user.preferences.reload
    render :update do |page|
      page.redirect_to(:action => 'list')
    end
  end

  def save_columns
    cols = params["displaycolumns"].find_all { |col| col unless col.blank? }
    pref = current_user.preferences
    pref.page_columns ||= {}
    current_user.preferences.page_columns[controller_name.to_sym] = cols
    current_user.preferences.save
    current_user.preferences.reload
    render :update do |page|
      page.redirect_to(:action => 'list')
    end
  end
  
  # TODO: recapture user column preferences by having a controller method
  #       list_columns that delegates to both the ui object and the user preferences
  # controller = controller.to_sym
  # session[:current_user] ? pref = session[:current_user].preferences : pref = nil
  #   
  # if pref && pref.page_columns && pref.page_columns.instance_of?(Hash) && pref.page_columns[controller]
  
end
module Streamlined::Helpers::MenuHelper
  attr_writer :streamlined_top_menus, :streamlined_side_menus
  def streamlined_side_menus
    @streamlined_side_menus ||= [
      ["TBD", {:action=>"new"}]
    ]
  end
  def streamlined_top_menus
    @streamlined_top_menus ||= [
      ["TBD", {:action=>"new"}]
    ]
  end
end
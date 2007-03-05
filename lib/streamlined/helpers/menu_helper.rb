module Streamlined::Helpers::MenuHelper
  # override these in your own application helper, or controller specific helpers
  def streamlined_side_menus
    [
      ["TBD", {:action=>"list"}]
    ]
  end
  def streamlined_top_menus
    [
      ["TBD", {:action=>"new"}]
    ]
  end
end
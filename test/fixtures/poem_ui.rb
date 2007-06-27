module PoemAdditions
  def text_with_div
    "<div>#{text}</div>"
  end
end

Poem.class_eval { include PoemAdditions }

class PoemUI < Streamlined::UI
  list_columns :text,
               :text_with_div,
               :poet, { :filter_column => "first_name" }
end
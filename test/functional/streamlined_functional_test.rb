require File.join(File.dirname(__FILE__), '../test_functional_helper')

class StreamlinedFunctionalTest < Test::Unit::TestCase
  
  def setup
    Streamlined::Registry.reset
  end
  
  def test_ui_for
    assert_instance_of(Streamlined::UI, poem_ui = Streamlined.ui_for(Poem))
    assert_instance_of(Streamlined::UI, poet_ui = Streamlined.ui_for(Poet))
    assert_same(poem_ui, Streamlined.ui_for(Poem), "registry should cache ui instances")
    assert_not_same(poet_ui, Streamlined.ui_for(Poem), "different names return different instances")
  end

  # TODO
  # def test_ui_for_do
  #   poem_ui = Streamlined.ui_for(Poem) do
  #     user_columns :text
  #   end
  # end
  
end

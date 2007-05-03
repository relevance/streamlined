class Poet < ActiveRecord::Base
  has_many :poems
  
  def arbitrary_instance_method
    "foo"
  end
end

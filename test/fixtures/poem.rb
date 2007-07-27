class Poem < ActiveRecord::Base
  belongs_to :poet
  delegates :first_name, :to => :poet
end

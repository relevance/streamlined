class Streamlined::Column::Base
  include ERB::Util
  attr_accessor :read_only
  def set_attributes(hash)
    hash.each do |k,v|
      sym = "#{k}="
      self.send sym, v
    end
  end
end
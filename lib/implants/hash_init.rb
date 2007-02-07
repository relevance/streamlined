module HashInit
  def initialize(hash={})
    hash.each do |k,v|
      sym = "#{k}="
      self.send sym, v
    end if hash
  end
end
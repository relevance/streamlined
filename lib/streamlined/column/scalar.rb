class Streamlined::Column::Scalar
  attr_accessor :name, :human_name

  def initialize(sym)
    @name = sym.to_s
    @human_name = sym.to_s.humanize
  end

  # Array#== calls this
  def ==(o)
    return true if o.object_id == object_id
    return false unless Streamlined::Column::Scalar === o
    return name.eql?(o.name)
  end
end

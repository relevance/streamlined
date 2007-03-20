class Module
  # Declare an attribute with an initial default 
  #
  # To give attribute :foo the initial value :bar
  # attr_with_default :foo, :bar
  #
  # To give attribute :foo a dynamic default value, evaluated
  # in scope of self
  # attr_with_default(:foo) {something_interesting}
  #
  def attr_with_default(sym, *rest, &proc)
    default = rest[0] unless rest.empty?
    raise 'default value or proc required' unless (default || proc)
    if default
      module_eval "def #{sym}; @#{sym}||=#{default}; end"
    end
    if proc
      define_method(sym) do
        self.instance_eval(&proc)
      end
    end
    module_eval <<-END
def #{sym}=(value)
  class << self ; attr_reader :#{sym} ; end
  @#{sym} = value
end
END
  end
end

class Streamlined::View::Base
  attr_reader :fields
  attr_reader :association
  attr_reader :separator
  
  # When creating a relationship manager, specify the list of fields that will be 
  # rendered at runtime.
  def initialize(options = {})
    @fields = options[:fields]
    @options = options
    @separator = options[:separator] || ":"
  end
  
  # Returns the string representation used to create JavaScript IDs for this relationship type.
  def id_fragment
    return Inflector.demodulize(self.class.name)
  end
  
  # Returns the path to the partial that will be used to render this relationship type.
  def partial
    mod = self.class.name.split("::")[-2]
    "../../vendor/plugins/streamlined/templates/relationships/#{mod.downcase}/#{Inflector.underscore(Inflector.demodulize(self.class.name))}"
  end
  
  
  private
  
  def dependency_satisfied(dep)
    results = true
    begin
      Class.class_eval(dep)
    rescue Exception => ex
      results = false
    end
    results
  end
  
end


class Module
  def dsl_scalar(*names)
    names.each do |name|
      method_body=<<-END
def #{name}(*args)    
  case args.length
  when 0
    @#{name}
  else
    @#{name} = args.first
  end
end
END
      self.module_eval(method_body)
    end
  end  
  def dsl_array(*names)
    names.each do |name|
      method_body=<<-END
def #{name}(*args)    
  @#{name} ||= []
  case args.length
  when 0
    @#{name}
  else
    @#{name} += args
  end
end
END
      self.module_eval(method_body)
    end
  end  
end
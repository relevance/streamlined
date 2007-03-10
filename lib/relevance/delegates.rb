module Relevance; end
module Relevance::Delegates
  # Provides an alternative to Rails' delegate method. We needed two things
  # that Rails did not do: delegate from one method name to another, and 
  # provide a default value if the delegate object is nil. :to is required
  # :method is optional (default is the method name being called)
  # :default is optional (default is to blow up if the delegate is nil)
  # 
  # Usage
  #   class Foo < ActiveRecord::Base
  #     delegate :hello, :goodbye, :to => :greeter, :method=>:salutation, :default=>'Cheers'
  #   end
  #
  def delegates(*methods)
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a :to option"
    end
    method_to, default = options[:method], options[:default]
    if default
      methods.each do |method_from|
        method = method_to ? method_to : method_from
        # TODO: how to pass a block?
        define_method(method_from) do |*args|
          self.send(to) ? self.send(to).send(method,*args) : default
        end
      end
    else
      methods.each do |method_from|
        method = method_to ? method_to : method_from
        module_eval(<<-EOS, "(__DELEGATION__)", 1)
          def #{method_from}(*args, &block)
            #{to}.__send__(#{method.inspect}, *args, &block)
          end
        EOS
      end
    end
  end
end
Module.class_eval {include Relevance::Delegates}


# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com

# TODO: Arguably belongs to Streamlined::Controller::Context
module Streamlined; end
require 'streamlined/reflection'

# Base class for the model-specific declarative UI controller classes.  Each Model class 
# will have a parallel class in the app/streamlined directory for managing the views.
# For example, if your application has two models, <tt>User</tt> and <tt>Role</tt> (in <tt>app/models/user.rb</tt> and <tt>role.rb)</tt>, 
# your Streamlined application would also have <tt>app/streamlined/user.rb</tt> and <tt>role.rb</tt>, containing the classes
# <tt>UserUI</tt> and <tt>RoleUI</tt>.  
class Streamlined::UI
  class << self
    include Streamlined::Reflection
    declarative_scalar :model,
                       :default_method => :default_model,
                       :writer => Proc.new{|x| Object.const_get(x.to_s.classify)}
    declarative_scalar :edit_link_column
    declarative_scalar :pagination, :default=>true
    declarative_scalar :table_row_buttons, :default=>true
    
    def inherited(subclass)
      # subclasses inherit some settings from superclass
      subclass.table_row_buttons(self.table_row_buttons)
    end      
    
    # Name of this class minus the "UI" suffix.
    def default_model
      raise ArgumentError, "You must set a model" if name.blank?
      Object.const_get(self.name.chomp("UI"))
    end

    # Define the columns that should be visible to the user at runtime.  There 
    # By default, user_columns excludes:
    # * any field whose name ends in "_at" (Rails-managed timestamp field)
    # * any field whose name ends in "_on" (Rails-managed timestamp field)
    # * any field whose name ends in "_id" (foreign key)
    # * the "position" field (Rails-managed ordering column)
    # * the "lock_version" field (Rails-managed optimistic concurrency)
    # * the "password_hash" field (if using a hashed-password strategy)
    def user_columns(*args)
      if args.size > 0
        @user_columns = []
        args.each do |arg|
          if Hash === arg
            @user_columns.last.set_attributes(arg)
          else
            col = column(arg)
            raise(Streamlined::Error,"No column named #{arg}") unless col
            @user_columns << col
          end
        end
      else
        @user_columns ||= all_columns.reject do |v|
          v.name.to_s.match /(_at|_on|position|lock_version|_id|password_hash|id)$/
        end
      end
    end

    def override_columns(name, *args)
      if args.size > 0
        instance_variable_set(name, [])
        args.each do |arg|
          if Hash === arg
            instance_variable_get(name).last.set_attributes(arg)
          else
            col = column(arg)
            raise(Streamlined::Error,"No column named #{arg}") unless col
            instance_variable_get(name) << Marshal::load(Marshal.dump(col))
          end
        end
      else
        instance_variable_get(name) || user_columns
      end
    end

    def show_columns(*args)
      override_columns(:@show_columns, *args)
    end
    def edit_columns(*args)
      override_columns(:@edit_columns, *args)
    end
    def list_columns(*args)
      override_columns(:@list_columns, *args)
    end
    
    def column(name)
      scalars[name] || additions[name] || relationships[name]
    end
    
    def scalars
      @scalars ||= reflect_on_scalars
    end
    
    def additions
      @additions ||= reflect_on_additions
    end
    
    def relationships
      @relationships ||= reflect_on_relationships
    end
    
    def all_columns
      @all_columns ||= (scalars.values + additions.values + relationships.values)
    end
 
    def generic_ui
      Streamlined::UI::Generic
    end
    
    def get_ui(klass_name)
      "#{klass_name}UI".to_const || generic_ui
    end

  end
end
require 'streamlined/ui/generic'

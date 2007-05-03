# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com

# TODO: Arguably belongs to Streamlined::Controller::Context
module Streamlined; end
require 'streamlined/reflection'

# Base class for the model-specific declarative UI controller classes.  Each Model class 
# will have a parallel class in the app/streamlined directory for managing the views.
# For example, if your application has two models, <tt>User</tt> and <tt>Role</tt> (in
# <tt>app/models/user.rb</tt> and <tt>app/models/role.rb)</tt>, your Streamlined application
# would also have <tt>app/streamlined/user.rb</tt> and <tt>app/streamlined/role.rb</tt>,
# containing the classes <tt>UserUI</tt> and <tt>RoleUI</tt>.  
class Streamlined::UI
  class << self
    include Streamlined::Reflection
    declarative_scalar :model,
                       :default_method => :default_model,
                       :writer => Proc.new{|x| Object.const_get(x.to_s.classify)}
    declarative_scalar :pagination, :default=>true
    declarative_scalar :table_row_buttons, :default=>true
    declarative_scalar :quick_delete_button, :default=>true    
    declarative_scalar :table_filter, :default=>true
    declarative_scalar :read_only, :default=>false
    
    def inherited(subclass) #:nodoc:
      # subclasses inherit some settings from superclass
      subclass.table_row_buttons(self.table_row_buttons)
      subclass.quick_delete_button(self.quick_delete_button)      
    end      
    
    # Returns the name of this class minus the "UI" suffix.
    def default_model
      raise ArgumentError, "You must set a model" if name.blank?
      Object.const_get(self.name.chomp("UI"))
    end

    # Defines the columns that should be visible to the user at runtime.  Takes an array
    # of column names.  For example:
    # 
    #   user_columns :login, :first_name, :last_name
    # 
    # Column order is reflected in the view. By default, user_columns excludes:
    # 
    # * Any field whose name ends in "_at" (Rails-managed timestamp field)
    # * Any field whose name ends in "_on" (Rails-managed timestamp field)
    # * Any field whose name ends in "_id" (foreign key)
    # * The "position" field (Rails-managed ordering column)
    # * The "lock_version" field (Rails-managed optimistic concurrency)
    # * The "password_hash" field (if using a hashed-password strategy)
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

    def override_columns(name, *args) #:nodoc:
      if args.size > 0
        instance_variable_set(name, [])
        args.each do |arg|
          if Hash === arg
            instance_variable_get(name).last.set_attributes(arg)
          else
            col = column(arg)
            
            # look for instance method
            unless col
              if model.method_defined?(arg)
                col = Streamlined::Column::Addition.new(arg)
              end
            end
            
            raise(Streamlined::Error,"No column named #{arg}") unless col
            
            # The line below used to marshal/unmarshal the column like so:
            #   instance_variable_get(name) << Marshal.load(Marshal.dump(col))
            #
            # Justin explained that this was leftover from a specific case where a Streamlined
            # user was storing the column in a database. It's not needed anymore.
            instance_variable_get(name) << col
          end
        end
      else
        instance_variable_get(name) || user_columns
      end
    end
    
    # Defines the columns that should be visible when the user clicks the
    # "Show" button at runtime.  Takes an array of column names.  For example:
    #
    #   show_columns :login, :first_name, :last_name
    #
    # Column order is reflected in the view. show_columns uses the same
    # default column exclusions as user_columns.
    def show_columns(*args)
      override_columns(:@show_columns, *args)
    end
    
    # Defines the columns that should be editable by the user at runtime.
    # Takes an array of column names.  For example:
    #
    #   edit_columns :login, :first_name, :last_name
    #
    # Column order is reflected in the view. edit_columns uses the same
    # default column exclusions as user_columns.
    def edit_columns(*args)
      override_columns(:@edit_columns, *args)
    end
    
    # Alias for user_columns (?)
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
    
    # Returns <tt>Streamlined::UI::Generic</tt>, the generic UI class.
    def generic_ui
      Streamlined::UI::Generic
    end
    
    # Returns the UI class for a given class name. If the named class has no associated
    # UI class, the generic_ui class will be returned.
    def get_ui(klass_name)
      "#{klass_name}UI".to_const || generic_ui
    end

  end
end
require 'streamlined/ui/generic'

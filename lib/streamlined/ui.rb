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
                       :writer => Proc.new { |x| x.is_a?(Class) ? x : x.to_s.classify.constantize }
    declarative_scalar :pagination, :default=>true
    declarative_scalar :table_row_buttons, :default=>true
    declarative_scalar :quick_delete_button, :default=>true    
    declarative_scalar :table_filter, :default=>true
    declarative_scalar :read_only, :default=>false
    declarative_scalar :new_submit_button, :default => {:ajax => true}
    declarative_scalar :mark_required_fields, :default=>true
    declarative_scalar :header_partials, :default => {}
    declarative_scalar :footer_partials, :default => {}
    
    def inherited(subclass) #:nodoc:
      # subclasses inherit some settings from superclass
      subclass.table_row_buttons(self.table_row_buttons)
      subclass.quick_delete_button(self.quick_delete_button)      
    end      
    
    # Returns the name of this class minus the "UI" suffix.
    def default_model
      raise ArgumentError, "You must set a model" if name.blank?
      self.name.chomp("UI").constantize
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
        convert_args_to_columns(:@user_columns, *args)
      else
        @user_columns ||= all_columns.reject do |v|
          v.name.to_s.match /(_at|_on|position|lock_version|_id|password_hash|id)$/
        end
      end
    end

    def override_columns(name, *args) #:nodoc:
      if args.size > 0
        convert_args_to_columns(name, *args)
      else
        instance_variable_get(name) || user_columns
      end
    end
    
    def convert_args_to_columns(name, *args) #:nodoc
      instance_variable_set(name, [])
      args.each do |arg|
        if Hash === arg
          instance_variable_get(name).last.set_attributes(arg)
        else
          col = column(arg)
          
          # look for instance method
          if col.nil? && model.method_defined?(arg)
            col = Streamlined::Column::Addition.new(arg, model)
          end
          
          raise(Streamlined::Error, "No column named #{arg}") unless col
          instance_variable_get(name) << col
        end
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

    # All required columns as specified by validation
    def required_columns
      all_columns.select { |col| col.validates_presence_of? }
    end
                  
    def id_fragment(relationship, crud_type)
      relationships[relationship.name].send("#{crud_type}_view").id_fragment  
    end
    
    def quick_add_columns(*args)
      if args.size > 0
        convert_args_to_columns(:@quick_add_columns, *args)
      else
        @quick_add_columns ||= user_columns.reject do |c|
          c.is_a?(Streamlined::Column::Addition)
        end
      end
    end
    
    # Creates a custom group of columns that doesn't override any of the standard
    # sets of columns. The only time this would be useful is if a custom view
    # needed access to Streamlined's nifty renderers outside of the traditional
    # list, show, edit, etc. column groups. For example:
    #
    #   custom_columns_group :group_name, :first_name, :last_name
    #
    # This code would create an instance variable called @group_name that would
    # contain the first_name and last_name columns. The group could then be
    # accessed inside a custom view this way:
    #
    #   <% for column in custom_columns_group(:group_name) %>
    #     ...
    #   <% end %>
    #
    def custom_columns_group(name, *args)
      name = "@#{name}".to_sym
      args.size > 0 ? convert_args_to_columns(name, *args) : instance_variable_get(name)
    end
    
    def column(name)
      scalars[name] || relationships[name] || delegations[name] || additions[name] 
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
    
    def delegations
      @delegations ||= reflect_on_delegates
    end
    
    def all_columns
      @all_columns ||= (scalars.values + additions.values + relationships.values + delegations.values)
    end
    
    # Returns <tt>Streamlined::UI::Generic</tt>, the generic UI class.
    def generic_ui
      Streamlined::UI::Generic
    end
    
    # Returns the UI class for a given model class name. If the named class has no associated
    # UI class, the generic_ui class will be returned.
    def get_ui(model_class)
      "#{model_class}UI".constantize
    rescue NameError
      ui = generic_ui
      ui.model = model_class
      ui
    end

  end
end
require 'streamlined/ui/generic'

# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com

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
       
    # Given a relationship name, returns the View class representing it.
    def view_def(rel)
      opts = relationships[rel.to_sym]
      Streamlined::View::EditViews.create_relationship(opts[:view],
                                                       opts[:view_fields])
    end
       
    # Given a relationship name, returns the Summary class representing it.
    def summary_def(rel)
      opts = relationships[rel.to_sym]
      Streamlined::View::ShowViews.create_summary(opts[:summary], opts[:fields])
    end
       
    def relationship(rel, opts = {:view => {}, :summary => {}})
      opts = force_options_to_current_syntax(opts)
      relationships[rel] = create_relationship(rel, opts)
    end

    def generic_ui
      Streamlined::UI::Generic
    end
    
    def get_ui(klass_name)
      if Object.const_defined?(klass_name + "UI")
        Class.class_eval(klass_name + "UI")
      else
        self.generic_ui
      end
    end

    private
    def force_options_to_current_syntax(opts)
      opts = {:view => {}, :summary => {} }.merge(opts)
      unless opts[:view].kind_of? Hash
        if opts[:view_fields]
          new_val = {:name => opts[:view], :fields => opts[:view_fields]}
        else
          new_val = {:name => opts[:view] }
        end
        opts[:view] = new_val
      end
      unless opts[:summary].kind_of? Hash
        if opts[:fields]
          new_val = {:name => opts[:summary], :fields => opts[:fields]}
        else
          new_val = {:name => opts[:summary] }
        end
        opts[:summary] = new_val
        end
      opts
    end

  end
end


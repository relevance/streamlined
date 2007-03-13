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
    declarative_array :popup_columns, :default=>[]
          
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
      return nil if opts[:summary] == :none
      Streamlined::View::ShowViews.create_summary(opts[:summary], opts[:fields])
    end
       
    # Used to override the default declarative values for a specific relationship.  Example usage:
    # <tt>relationship :books, :view => :inset_table, :summary => :list, :fields => [:title, :author]</tt>
    # Shows the list of all related books inline as [title]:[author]
    # When expanded, uses an inset table to show the books.
    # 
    # Currently available Views:
    # * :membership => simple scrollable list of checkboxes.  DEFAULT for n_to_many
    # * :inset_table => full table view inserted into current table
    # * :window => same table from :inset_table but displayed in a window
    # * :filter_select => like :membership, but with an auto-filter text box and two checkbox lists, one for selected and one for unselected items
    # * :polymorphic_membership => like :membership, but for polymorphic associations.  DEPRECATED: :membership will be made to handle this case.
    # * :select => drop down box.  DEFAULT FOR n_to_one
    #
    # Currently available Summaries:
    # * :count => number of associated items. DEFAULT FOR n_to_many
    # * :name => name of the associated item. DEFAULT FOR n_to_one
    # * :list => list of data from specified :fields
    # * :sum => sum of values from a specific column of the associated items
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
      return {:summary => :none} if [:off, :false, :none, false].include? opts
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


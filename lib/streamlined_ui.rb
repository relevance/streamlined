# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com

module Streamlined
# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com
#
# Base class for the model-specific declarative UI controller classes.  Each Model class 
# will have a parallel class in the app/streamlined directory for managing the views.
# For example, if your application has two models, <tt>User</tt> and <tt>Role</tt> (in <tt>app/models/user.rb</tt> and <tt>role.rb)</tt>, 
# your Streamlined application would also have <tt>app/streamlined/user.rb</tt> and <tt>role.rb</tt>, containing the classes
# <tt>UserUI</tt> and <tt>RoleUI</tt>.  
  class UI
    class << self
      
     def column_header( column )
          return "" if column.nil?

          column_name = column.name.to_sym

          return column.human_name if @column_headers.nil?
          return @column_headers[ column_name ] unless @column_headers[ column_name ].nil?
          return column.human_name
      end
      
      # Method that gets hooked into Rails' application reloading mechanism.  Resets all class variables
      # for the controller, enabling clean resets in development mode.
      def reset_subclasses
        ObjectSpace.each_object(Class) do |klass|
          if klass.ancestors[1..-1].include?(Streamlined::UI)
            RAILS_DEFAULT_LOGGER.debug "resetting streamlined class #{klass}"
         	  klass.instance_variables.each do |var|
         	    klass.send(:remove_instance_variable, var)
        	 	end
        	 	klass.instance_methods(false).each do |m|
        	 	  klass.send :undef_method, m
        	 	end
        	 end
         end
      end
       
       # The default model name is the name of this class minus the "UI" suffix.
       def default_model
          Object.const_get(self.name.chomp("UI"))
       end
       
       declarative_scalar :model,
                          :default_method => :default_model,
                          :writer => Proc.new{|x| Object.const_get(x.to_s.classify)}
       declarative_scalar :edit_link_column
       declarative_scalar :pagination, :default=>true
       
       # Used to define the columns that should be visible to the user at runtime.  There 
       # are two options: 
       # * <b>:include</b> : an array of columns to include, override the default exclusions.
       # * <b>:exclude</b> : an array of columns to exlude, adds to the default exclusions.
       # By default, user_columns excludes:
       # * any field whose name ends in "_at" (Rails-managed timestamp field)
       # * any field whose name ends in "_on" (Rails-managed timestamp field)
       # * any field whose name ends in "_id" (foreign key)
       # * the "position" field (Rails-managed ordering column)
       # * the "lock_version" field (Rails-managed optimistic concurrency)
       # * the "password_hash" field (if using a hashed-password strategy)
       def user_columns(options = {})
         initialize_user_columns
         
         excludes = options[:exclude]
         if excludes
           excludes = excludes.map &:to_s 
           @user_columns.reject! {|col| excludes.include? col.name}
         end
         
         includes = options[:include]
          if includes
             includes = includes.map &:to_s
             includes.reject! {|name| (@user_columns.collect {|col| col.name}).include? name }
             @user_columns.concat model.columns.select {|col| includes.include? col.name }
             # @user_columns.concat calculated_columns.select {|col| includes.include? col.name }
          end
          @user_columns
       end
       
         def column_headers( options )
              @column_headers = options[ :headers ]
          end
          
           def default_columns( options = {} )
             default_list_columns = options[ :columns ]
              if default_list_columns.nil?
                  @default_list_columns = @user_columns
              else
                 default_list_columns = default_list_columns.map(&:to_s)
                 @default_list_columns = default_list_columns.map do |column_name|
                     user_columns_for_display.find do |display_column|
                         display_column.name == column_name
                     end
                 end
              end
              @default_list_columns
           end
           
             def user_default_columns_for_display
                  unless @default_list_columns.nil?
                      return @default_list_columns 
                  end
                  return user_columns_for_display
              end
       
       # Used to return the currently defined user_columns collection.
       def user_columns_for_display
          @user_columns || initialize_user_columns
       end
       
       # Given a relationship name, returns the View class representing it.
       def view_def(rel)
         opts = self.relationships[rel.to_sym]
         Streamlined::Relationships::Views.create_relationship(opts[:view], opts[:view_fields])
       end
       
       # Given a relationship name, returns the Summary class representing it.
       def summary_def(rel)
         opts = self.relationships[rel.to_sym]
         return nil if opts[:summary] == :none
         Streamlined::Relationships::Summaries.create_summary(opts[:summary], opts[:fields])
       end
       
       # Return list of all known relationships.
       def relationships
         
         if @relationships && @relationships != {}
         
           @relationships 
         else
         
           initialize_relationships
           
           return @relationships
         end
       end
       
       # Returns a list of all columns, both ActiveRecord and calculated
        def all_columns
         @user_columns
        end

        # Sets or returns list of calculated columns. DEPRECATED: will not be needed in 0.0.5
        # def calculated_columns(*args)
        #  case args.length
        #  when 0
        #    []
        #  else
        #    base = []
        #    args.inject(base) {|base, a| base << Streamlined::Column.new(a)}
        #    base
        #  end
        # end
        
        declarative_array :calculated_columns,
                          :default=>[],
                          :writer=>Proc.new {|x| x.map {|item| Streamlined::Column.new(item)}}
        declarative_array :popup_columns, :default=>[]
              
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
           
           association = model.reflect_on_association(rel)
           raise Exception, "STREAMLINED ERROR: No association '#{rel}' on class #{model}." unless association
           
           ensure_options_parity(opts, association)
           
           initialize_relationships unless @relationships
           options = self.define_association(association, opts)
           if options[:summary] == :none
             @relationships[rel] = Streamlined::Relationships::Association.new(model.reflect_on_association(rel),nil, nil)
           else
             @relationships[rel] = Streamlined::Relationships::Association.new(model.reflect_on_association(rel), Streamlined::Relationships::Views.create_relationship(options[:view][:name], options[:view].reject {|k,v| k == :name}), Streamlined::Relationships::Summaries.create_summary(options[:summary][:name], options[:summary].reject {|k,v| k == :name}))         
           end
         end

         # Used to define the default relationship declarations for each relationship in the model.
         # n-to-many relationships default to the :membership view and the :count summary
         # n-to-one relationships default to the :select view and the :name summary
         def define_association(assoc, options = {:view => {}, :summary => {}})
           return {:summary => :none} if options[:summary] == :none
           case assoc.macro
           when :has_one, :belongs_to
             if assoc.options[:polymorphic]
               return {:view => {:name => :polymorphic_select}.merge(options[:view]), :summary => {:name => :name}.merge(options[:summary])}
             else
               return {:view => {:name => :select}.merge(options[:view]), :summary => {:name => :name}.merge(options[:summary])}
             end
           when :has_many, :has_and_belongs_to_many
             if assoc.options[:polymorphic]
               return {:view => {:name => :polymorphic_membership}.merge(options[:view]), :summary => {:name => :count}.merge(options[:summary])}
             else
               return {:view => {:name => :membership}.merge(options[:view]), :summary => {:name => :count}.merge(options[:summary])}
             end           
           end
         end  
        
       
       private
       
       # Causes all relationships to be initialized to default values
       def initialize_relationships
         @relationships = {}
           self.default_model.reflect_on_all_associations.each do |assoc|
              relationship(assoc.name.to_sym, self.define_association(assoc)) unless @relationships[assoc.name.to_sym]
           end
         @relationships

       end
       
       # Intializes the user_columns using a regex match to eliminate the unneeded columns from the Model's default columns collection.
       def initialize_user_columns
         @user_columns = model.columns.reject {|d| d.name.match /(_at|_on|position|lock_version|_id|password_hash|id)$/ }
         if Object.const_defined?(model.name + "Additions")
           @user_columns.concat(calculated_columns(*Class.class_eval(model.name + "Additions").instance_methods)) 
         end
         return @user_columns
       end
       
       # Enforce parity of options on any relationship declaration.
       # * use of the :list summary requires a :fields declaration
       def ensure_options_parity(options, association)
        RAILS_DEFAULT_LOGGER.debug("ensure_options_parity: #{options.inspect}, #{association.inspect}")
        return if options == nil || options = {}
        raise ArgumentError, "STREAMLINED ERROR: Error in #{self.name} : Cannot specify *:summary => :list* without also specifying the :fields option (#{options.inspect})" if options[:summary] && options[:summary][:name] == :list && !options[:summary][:fields]
        raise ArgumentError, "STREAMLINED ERROR: Error in #{self.name} : Cannot use *:summary => :name* for a #{association.macro} relationship" if options[:summmary] && options[:summary][:name] == :name && [:has_many, :has_and_belongs_to_many].include?(association.macro)  
        raise ArgumentError, "STREAMLINED ERROR: Error in #{self.name} : Cannot use *:view => :filter_select* for a #{association.macro} relationship" if options[:view] && options[:view][:name] == :filter_select && [:has_one, :belongs_to].include?(association.macro)  
       end
       
       
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
  
  class GenericUI < Streamlined::UI

     def self.user_columns_for_display
        initialize_user_columns
     end

      def self.initialize_user_columns
       user_columns = model.columns.reject {|d| d.name.match /(_at|_on|position|lock_version|_id|password_hash|id)$/ }
       if Object.const_defined?(model.name + "Additions")
         user_columns.concat(calculated_columns(*Class.class_eval(model.name + "Additions").instance_methods)) 
       end
       return user_columns
      end

      def self.all_columns
       initialize_user_columns
      end
      
      def self.default_model
        @model
      end
      
      def self.relationships
        return initialize_relationships
      end
      
   end

   def self.generic_ui
     GenericUI
   end
  
  
   def self.get_ui(klass_name)
     if Object.const_defined?(klass_name + "UI")
       Class.class_eval(klass_name + "UI")
     else
       self.generic_ui
     end
   end
  
   # Imitates ActiveRecord's Column, for use as wrapper around calculated columns.
   class Column
     attr_accessor :name, :human_name

     def initialize(sym)
       @name = sym.to_s
       @human_name = sym.to_s.humanize
     end

     # Array#== calls this
     def ==(o)
       return true if o.object_id == object_id
       return false unless Column === o
       return name.eql?(o.name)
     end
     
   end
end


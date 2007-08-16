# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com

# TODO: Arguably belongs to Streamlined::Controller::Context
module Streamlined; end
require 'streamlined/reflection'

# Model-specific UI. Each Model class will have a parallel model_ui.rb 
# in the app/streamlined directory for managing the views.
# For example, if your application has two models, <tt>User</tt> and <tt>Role</tt> (in
# <tt>app/models/user.rb</tt> and <tt>app/models/role.rb)</tt>, your Streamlined application
# would also have <tt>app/streamlined/user_ui.rb</tt> and <tt>app/streamlined/role_ui.rb</tt>,
# containing the classes <tt>UserUI</tt> and <tt>RoleUI</tt>.  
class Streamlined::UI
  include Streamlined::Reflection
  attr_accessor :model
  declarative_scalar :pagination, :default => true
  declarative_scalar :table_row_buttons, :default => true
  declarative_scalar :quick_delete_button, :default => true
  declarative_scalar :quick_edit_button, :default => true
  declarative_scalar :quick_new_button, :default => true
  declarative_scalar :table_filter, :default => true
  declarative_scalar :read_only, :default => false
  declarative_scalar :new_submit_button, :default => {:ajax => true}
  declarative_scalar :edit_submit_button, :default => {:ajax => true}
  declarative_scalar :mark_required_fields, :default => true
  declarative_scalar :header_partials, :default => {}
  declarative_scalar :after_header_partials, :default => {}
  declarative_scalar :footer_partials, :default => {}
  declarative_scalar :style_classes, :default => {}
  declarative_scalar :default_order_options, :default => {},
                     :writer => Proc.new { |x| x.is_a?(Hash) ? x : {:order => x}}
  declarative_attribute '*args', :exporters, :default => [:csv, :json, :xml]
  
  def initialize(model, &blk)
    @model = String === model ? model.constantize : model
    self.instance_eval(&blk) if block_given?
  end
  
  def inherited(subclass) #:nodoc:
    # subclasses inherit some settings from superclass
    subclass.table_row_buttons(self.table_row_buttons)
    subclass.quick_delete_button(self.quick_delete_button)
    subclass.quick_edit_button(self.quick_edit_button)
    subclass.quick_new_button(self.quick_new_button)
    subclass.exporters(*self.exporters)
  end      
  
  def style_class_for(crud_context, table_context, item)
    crud_classes = style_classes[crud_context]
    style_class = crud_classes[table_context] if crud_classes
    style_class.respond_to?(:call) ? style_class.call(item) : style_class
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
        if col.nil?
          col = Streamlined::Column::Addition.new(arg, model)
        end
        # @user_columns not dup'ed so they act as default for other groups
        col = col.dup unless name.to_s == "@user_columns"
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
  
  def has_columns_group?(name)
    instance_variable_get("@#{name}")
  end
  
  def column(name, options={})
    if options[:crud_context]
      # find the column within a specific group
      send("#{options[:crud_context]}_columns").find {|col| col.name.to_s == name.to_s}
    else
      # find the template column used to build the various groups
      scalars[name] || relationships[name] || delegations[name] || additions[name] 
    end
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
  
  def conditions_by_like_with_associations(value)
    column_pairs = model.user_columns.collect { |c| "#{model.table_name}.#{c.name}" }
    filterable_associations.each { |c| column_pairs << "#{c.name.to_s.tableize}.#{c.filter_column}" }
    conditions = column_pairs.collect { |c| "#{c} LIKE #{ActiveRecord::Base.connection.quote("%#{value}%")}" }
    conditions.join(" OR ")
  end
  
  # Returns all list columns that can be filtered. A list column is considered
  # filterable if its :filter_column option is set.
  def filterable_associations
    list_columns.select { |c| c.association? && c.filterable? }
  end

  def displays_exporter?(exporter)
    if exporters.is_a?(Array)
      exporters.include?(exporter)
    else
      exporters == exporter
    end
  end 
end
require 'streamlined/ui/deprecated'

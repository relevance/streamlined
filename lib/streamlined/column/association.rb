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

# Wrapper around ActiveRecord::Association.  Keeps track of the underlying association, the View definition and the Summary definition.
class Streamlined::Column::Association < Streamlined::Column::Base
  attr_reader :underlying_association
  attr_accessor :human_name
  attr_reader :edit_view, :show_view
  attr_with_default :quick_add, 'true'
  delegates :name, :class_name, :to=>:underlying_association
  
  def initialize(assoc, parent_model, edit, show)
    @underlying_association = assoc
    @parent_model = parent_model
    self.edit_view = edit
    self.show_view = show
    @human_name = name.to_s.humanize
  end
  
  def belongs_to?
    underlying_association.macro == :belongs_to
  end

  def edit_view=(opts)
    @edit_view = case(opts)
    when(Symbol)
      Streamlined::View::EditViews.create_relationship(opts)
    when(Array)
      Streamlined::View::EditViews.create_relationship(*opts)
    when(Streamlined::View::Base)
      opts
    else
      raise ArgumentError, opts.class.to_s
    end
  end
  
  def show_view=(opts)
    @show_view = case(opts)
    when(Symbol)
      Streamlined::View::ShowViews.create_summary(opts)
    when(Array)
      Streamlined::View::ShowViews.create_summary(*opts)
    when(Streamlined::View::Base)
      opts
    else
      raise ArgumentError, opts.class.to_s
    end
  end

  # Returns a list of all the classes that can be used to satisfy this relationship.  In a polymorphic relationship, it is the union 
  # of every type that is configured :as the relationship type.  For direct associations, it is the listed type of the relationship.      
  def associables             
    return [@underlying_association.class_name.constantize] unless @underlying_association.options[:polymorphic]
    results = []
    ObjectSpace.each_object(Class) do |klass|
      results << klass if klass.ancestors.include?(ActiveRecord::Base) && klass.reflect_on_all_associations.collect {|a| a.options[:as]}.include?(@underlying_association.name)
    end
    return results
  end
  
  # Returns an array of all items that can be selected for this association.
  def items_for_select
    klass = Class.class_eval(class_name)
    if associables.size == 1
      klass.find(:all)
    else
      items = {}
      associables.each { |klass| items[klass.name] = klass.find(:all) }
      items
    end
  end
  
  def render_td_show(view, item)
    id = relationship_div_id(name, item, class_name)
    div = div_wrapper(id) do
      view.render(:partial => show_view.partial, 
                  :locals => { :item => item, :relationship => self, 
                  :streamlined_def => show_view })
    end
  end
  
  def render_td_list(view, item)
    id = relationship_div_id(name, item, class_name)
    div = render_td_show(view, item)
    div += view.link_to_function("Edit", "Streamlined.Relationships." <<
      "open_relationship('#{id}', this, '/#{view.controller_name}')") if editable
    div
  end
  
  def render_td_edit(view, item)
    # TODO: I was only able to implement editable associations for belongs_to
    result = "[TBD: editable associations]"
    if item.respond_to?(name_as_id)
      choices = items_for_select.collect { |e| [e.streamlined_name(edit_view.fields, edit_view.separator), e.id] }
      choices.unshift(unassigned_option) if column_can_be_unassigned?(parent_model, name_as_id.to_sym)
      selected_choice = item.send(name).id if item.send(name)
      result = view.select(model_underscore, name_as_id, choices, :selected => selected_choice)
      result += render_quick_add(view) if should_render_quick_add?(view)
    end
    wrap(result)
  end 
  alias :render_td_new :render_td_edit
  
  def render_quick_add(view)
    image = view.image_tag('streamlined/add_16.png', :alt => 'Quick Add', :title => 'Quick Add', :border => '0', :hspace => 2)
    url = view.url_for(:action => 'quick_add', :model_class_name => class_name, :select_id => form_field_id)
    view.link_to_function(image, "Streamlined.QuickAdd.open('#{url}')")
  end
  
  def should_render_quick_add?(view)
    quick_add && belongs_to? && view.params[:action] != 'quick_add'
  end
end

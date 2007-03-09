module Streamlined::View::ShowViews
  
  # Factory method for creating a relationship Summary given the name of a summary.
  def self.create_summary(sym, options = nil)
    if options
      Class.class_eval(Inflector.camelize(sym.to_s)).new options
    else
      Class.class_eval(Inflector.camelize(sym.to_s)).new
    end
  end

  # TODO: this is not very dry!
  class Link < Streamlined::Column::View

  end      
  
  # Renders a count of the total number of members of this collection.
  class Count < Streamlined::Column::View
    
  end
  
  # Renders a list of values, as defined by the #fields attribute.  For each member of the collection, renders those 
  # fields in a concatenated string.
  class List < Streamlined::Column::View

  end
  
  # Renders the sum of a given attribute of the related @models.  The field is specified as the single member of the #fields attribute.
  class Sum < Streamlined::Column::View

  end
  
  # Renders the average of a given attribute of the related @models.  The field is specified as the single member of the #fields attribute.
  class Average < Streamlined::Column::View

  end
  
  
  # Renders the streamlined_name of the other end of the relationship.  Used for n-to-one relationships.
  class Name < Streamlined::Column::View
    
  end
  
  class Graph < Streamlined::Column::View                            
    def graph_data(item, relationship)
      raise "STREAMLINED ERROR: Cannot use the Sparklines Graph relationship summary: need to install Sparklines plugin first (requires RMagick, which is not the easiest thing to install, we're just warning you)" unless dependency_satisfied('Sparklines')
      if block_given?
        return yield(item, relationship)
      else
        case @options[:type].to_sym
        when :pie
          RAILS_DEFAULT_LOGGER.debug("DATA: #{(item.send(relationship.name).size/relationship.klass.count)*100}")
          return [(item.send(relationship.name).size.to_f/relationship.klass.count.to_f)*100]
        else
          return [0]
        end
      end
    end
    
    def graph_options
      @options
    end
    
  end
  
  # Suppresses in-line relationship rendering.
  class None < Streamlined::Column::View
  end
end

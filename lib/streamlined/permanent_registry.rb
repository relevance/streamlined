# Provides a registry hook for global items that should never be reloaded 
# (e.g., items registered in environment.rb).
class Streamlined::PermanentRegistry  
  
  @display_formats_by_matcher = {}
  
  class << self
    def display_format_for(matcher, &proc)
      raise ArgumentError, "Block required" unless block_given?
      @display_formats_by_matcher[matcher] = proc
    end                                                        
    def format_for_display(object)
      @display_formats_by_matcher.each do |k,v|
        if k === object
          return v.call(object)
        end
      end
      object
    end
    def reset
      @display_formats_by_matcher = {}
    end
  end
end


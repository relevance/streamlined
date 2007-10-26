module MultiRails

  # Simple config object
  class Config
    @weird_versions = { "2.0.0.PR" => "1.2.4.7794" }
    @rails_requires = %w[active_support
                         active_record 
                         action_controller 
                         action_controller/test_process]
    
    class << self
      attr_accessor :weird_versions, :rails_requires
      def version_lookup(version = nil)
        return named_version_lookup(version) if version
        return named_version_lookup(ENV["MULTIRAILS_RAILS_VERSION"]) if ENV['MULTIRAILS_RAILS_VERSION']
        Loader.latest_stable_version
      end
      
      def named_version_lookup(pretty_version)
        version = @weird_versions[pretty_version] || pretty_version
        raise MultiRailsError, "Can't find Rails gem version #{pretty_version} - available versions are: #{Loader.all_rails_versions.to_sentence})." if !Loader.all_rails_versions.include? version
        version
      end
      
    end
  end
  
end
module MultiRails

  class Loader
    attr_reader :version
    
    def self.logger
      @logger ||= Logger.new(STDOUT)
    end
    
    # Require and gem rails
    # Will use a default version if none is supplied
    def self.gem_and_require_rails(rails_version = nil)
      rails_version = MultiRails::Config.version_lookup(rails_version)
      Loader.new(rails_version).gem_and_require_rails
    end
    
    # Returns a list of all Rails versions available, oldest first
    def self.all_rails_versions
      specs = Gem::cache.find_name("rails")
      specs.map {|spec| spec.version.to_s }.sort
    end
    
    def self.latest_stable_version
      all_rails_versions.sort.reverse.detect {|version| version.count(".") < 3 }
    end
    
    # A version of the loader is created to gem and require one version of Rails
    def initialize(version)
      @version = version
    end
    
    # Gem a version of Rails, and require appropriate files
    def gem_and_require_rails
      gem_rails
      require_rails
    end
    
    def gem_rails
      gem 'rails', version
    rescue LoadError => e
      msg = %Q[Cannot find gem for Rails version: '#{version}'!\nInstall the missing gem with:\ngem install -v=#{version} rails]
      raise MultiRailsError, msg
    end
    
    def require_rails
      Config.rails_requires.each {|lib| require lib }
    end
  end
  
end
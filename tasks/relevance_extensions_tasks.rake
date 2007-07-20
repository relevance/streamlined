# Handle copying over the default assets, views, and layout that Streamlined depends on.
# We don't do all this in the rake task to make things easier to test.
module Streamlined
  class Assets
    @default_javascripts = ["rico_corner.js", "streamlined.js", "tabber.js", "tabber-minimized.js"]
    @default_stylesheets = ["streamlined.css", "as_style.css", "menu.css", "tabber.css"]
    @default_layout = ["streamlined.rhtml"]
    @asset_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'files'))
    class << self 
      attr_accessor :default_javascripts, :default_stylesheets, :default_layout
      attr_reader :asset_dir, :rails_root
    end

    def self.normalize_asset(path)
      File.join(asset_dir, path)
    end

    def self.copy(src, dest)
      FileUtils.cp_r src, dest
    end
    
    def self.install(files, *dest)
      files.each { |file| copy(normalize_asset(file), File.join(RAILS_ROOT, dest)) }
    end
  
    # copy over streamlined required js and some small js libraries we depend on 
    def self.install_javascripts
      install default_javascripts, "public", "javascripts"
      install "overlib", "public", "javascripts"
      install "windows_js", "public", "javascripts"
    end
    
    def self.install_stylesheets
      install default_stylesheets, "public", "stylesheets"
    end
    
    def self.install_layout
      install default_layout, "app", "views", "layouts"
    end
    
    def self.install_images
      install "images", "public", "images", "streamlined"
    end
    
    def self.install_partials
      install "partials", "app", "views", "shared", "streamlined"
    end
    
  end  
end

namespace :streamlined do
  
  desc 'Install Streamlined required files.'
  task :install_files do  
    Streamlined::Assets.install_javascripts
    Streamlined::Assets.install_stylesheets
    Streamlined::Assets.install_layout
    
    Streamlined::Assets.install_overlib
    Streamlined::Assets.install_windows_js
    Streamlined::Assets.install_images
    Streamlined::Assets.install_partials
  end
  
  desc 'Create the StreamlinedUI file for one or more models.'
  task :model => :environment do
    raise "Must specify at least one model name using MODEL=." unless ENV['MODEL']
    
    ui_template = ERB.new <<-TEMPLATE
module <%= model %>Additions

end
<%= model %>.class_eval {include <%= model %>Additions}

class <%= model %>UI < Streamlined::UI

end   
    TEMPLATE

    unless FileTest.exist? File.join(RAILS_ROOT, 'app', 'streamlined')
      FileUtils.mkdir(File.join(RAILS_ROOT, 'app', 'streamlined'))
    end

    ENV['MODEL'].split(',').each do |model|
      file_name = "#{model.underscore}_ui.rb"

      unless FileTest.exist? File.join(RAILS_ROOT, 'app', 'streamlined', file_name)
          File.open(File.join(RAILS_ROOT, 'app', 'streamlined', file_name), "a") { |f|
             f << ui_template.result(binding)
          }
      end
    end
  end
end
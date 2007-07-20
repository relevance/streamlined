# Handle copying over the default assets, views, and layout that Streamlined depends on.
# We don't do all this in the rake task to make things easier to test.
module Streamlined
  class Assets
    @source = File.expand_path(File.join(File.dirname(__FILE__), '..', 'files'))
    @destination = RAILS_ROOT
    class << self 
      attr_accessor :source, :destination
    end

    def self.install
      files = Dir.glob("#{source}/**/*")
      files.each { |file| FileUtils.cp_r(file, destination) }
    end
    
  end  
end

namespace :streamlined do
  
  desc 'Install Streamlined required files.'
  task :install_files do  
    Streamlined::Assets.install
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
namespace :streamlined do
  desc 'Force install of plugin-related files.'
  task :install_files do
    begin
      FileUtils.cp  File.join(File.dirname(__FILE__), '..', 'files', 'rico_corner.js'), File.join(RAILS_ROOT, 'public', 'javascripts')
      FileUtils.cp  File.join(File.dirname(__FILE__), '..', 'files', 'streamlined.js'), File.join(RAILS_ROOT, 'public', 'javascripts')
      FileUtils.cp  File.join(File.dirname(__FILE__), '..', 'files', 'streamlined.rhtml'), File.join(RAILS_ROOT, 'app', 'views', 'layouts')
      FileUtils.cp  File.join(File.dirname(__FILE__), '..', 'files', 'streamlined.css'), File.join(RAILS_ROOT, 'public', 'stylesheets')
      FileUtils.cp  File.join(File.dirname(__FILE__), '..', 'files', 'as_style.css'), File.join(RAILS_ROOT, 'public', 'stylesheets')
      FileUtils.cp  File.join(File.dirname(__FILE__), '..', 'files', 'menu.css'), File.join(RAILS_ROOT, 'public', 'stylesheets')
      FileUtils.cp_r  File.join(File.dirname(__FILE__), '..', 'files', 'overlib'), File.join(RAILS_ROOT, 'public')
      FileUtils.cp_r  File.join(File.dirname(__FILE__), '..', 'files', 'windows_js'), File.join(RAILS_ROOT, 'public')

      unless FileTest.exist? File.join(RAILS_ROOT, 'public', 'images', 'streamlined')
        FileUtils.mkdir_p( File.join(RAILS_ROOT, 'public', 'images', 'streamlined') )
      end

      FileUtils.cp( 
        Dir[File.join(File.dirname(__FILE__), '..', 'files', 'images', '*.png')] + Dir[File.join(File.dirname(__FILE__), '..', 'files', 'images', '*.gif')], 
        File.join(RAILS_ROOT, 'public', 'images', 'streamlined'),
        :verbose => true
      )

      unless FileTest.exist? File.join(RAILS_ROOT, 'app', 'views', 'shared', 'streamlined')
        FileUtils.mkdir_p(File.join(File.join(RAILS_ROOT, 'app', 'views', 'shared', 'streamlined')))
      end

      FileUtils.cp(
       Dir[File.join(File.dirname(__FILE__), '..', 'files', 'partials', '*.rhtml')],
       File.join(RAILS_ROOT, 'app', 'views', 'shared', 'streamlined'),
       :verbose => true
      )

    rescue Exception => ex
      puts "FAILED TO COPY FILES DURING FORCE INSTALL OF STREAMLINED."
      puts "EXCEPTION: #{ex}"
    end  
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
      FileUtils.mkdir(File.Join(RAILS_ROOT, 'app', 'streamlined'))
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
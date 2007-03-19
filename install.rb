# Install hook code here
begin
  FileUtils.cp  File.join(File.dirname(__FILE__), 'files', 'streamlined.js'), File.join(File.dirname(__FILE__), '..','..','..', 'public', 'javascripts')
  FileUtils.cp  File.join(File.dirname(__FILE__), 'files', 'streamlined.rhtml'), File.join(File.dirname(__FILE__), '..','..','..', 'app', 'views', 'layouts')
  FileUtils.cp  File.join(File.dirname(__FILE__), 'files', 'streamlined.css'), File.join(File.dirname(__FILE__), '..','..','..', 'public', 'stylesheets')
  FileUtils.cp  File.join(File.dirname(__FILE__), 'files', 'as_style.css'), File.join(File.dirname(__FILE__), '..','..','..', 'public', 'stylesheets')
  FileUtils.cp  File.join(File.dirname(__FILE__), 'files', 'menu.css'), File.join(File.dirname(__FILE__), '..','..','..', 'public', 'stylesheets')
  FileUtils.cp_r  File.join(File.dirname(__FILE__), 'files', 'overlib'), File.join(File.dirname(__FILE__), '..','..','..', 'public')
  FileUtils.cp_r  File.join(File.dirname(__FILE__), 'files', 'windows_js'), File.join(File.dirname(__FILE__), '..','..','..', 'public')
  
  unless FileTest.exist? File.join(File.dirname(__FILE__), '..','..','..', 'public', 'images', 'streamlined')
    FileUtils.mkdir_p( File.join(File.dirname(__FILE__), '..','..','..', 'public', 'images', 'streamlined') )
  end
  
  FileUtils.cp( 
    Dir[File.join(File.dirname(__FILE__), 'files', 'images', '*.png')] + Dir[File.join(File.dirname(__FILE__), 'files', 'images', '*.gif')], 
    File.join(File.dirname(__FILE__), '..','..','..', 'public', 'images', 'streamlined'),
    :verbose => true
  )
  
  unless FileTest.exist? File.join(File.dirname(__FILE__), '..','..','..', 'app', 'views', 'shared', 'streamlined')
    FileUtils.mkdir_p(File.join(File.join(File.dirname(__FILE__), '..','..','..', 'app', 'views', 'shared', 'streamlined')))
  end
  
  FileUtils.cp(
   Dir[File.join(File.dirname(__FILE__), 'files', 'partials', '*.rhtml')],
   File.join(File.dirname(__FILE__), '..','..','..', 'app', 'views', 'shared', 'streamlined'),
   :verbose => true
  )
  
rescue Exception => ex
  puts "FAILED TO COPY FILES DURING STREAMLINED INSTALL.  PLEASE RUN rake streamlined:install_files."
  puts "EXCEPTION: #{ex}"
end
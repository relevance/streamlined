# Install hook code here
begin
  FileUtils.cp  File.join(File.dirname(__FILE__), 'files', 'rico_corner.js'), File.join(RAILS_ROOT, 'public', 'javascripts')
  FileUtils.cp  File.join(File.dirname(__FILE__), 'files', 'streamlined.js'), File.join(RAILS_ROOT, 'public', 'javascripts')
  FileUtils.cp  File.join(File.dirname(__FILE__), 'files', 'streamlined.rhtml'), File.join(RAILS_ROOT, 'app', 'views', 'layouts')
  FileUtils.cp  File.join(File.dirname(__FILE__), 'files', 'streamlined.css'), File.join(RAILS_ROOT, 'public', 'stylesheets')
  FileUtils.cp_r  File.join(File.dirname(__FILE__), 'files', 'overlib'), File.join(RAILS_ROOT, 'public')
  FileUtils.cp_r  File.join(File.dirname(__FILE__), 'files', 'windows_js'), File.join(RAILS_ROOT, 'public')
  FileUtils.cp_r  File.join(File.dirname(__FILE__), 'files', 'grids'), File.join(RAILS_ROOT, 'public', 'stylesheets')
  FileUtils.cp_r  File.join(File.dirname(__FILE__), 'files', 'images'), File.join(RAILS_ROOT, 'public', 'images', 'streamlined')
rescue Exception => ex
  puts "FAILED TO COPY FILES DURING STREAMLINED INSTALL.  PLEASE RUN rake streamlined:install_files."
  puts "EXCEPTION: #{ex}"
end
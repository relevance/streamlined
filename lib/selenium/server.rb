require 'rubygems'
require 'daemons'

options = {
  :backtrace  => true,
  :log_output => true,
  :monitor    => true, 
}

LOG_BASE_FILE_NAME = 'tmp/selenium/selenium'
SELENIUM_JAR = File.expand_path(File.join(File.dirname(__FILE__), 'server/selenium-server-0.9.2-SNAPSHOT-standalone.jar'))

Daemons.run_proc(LOG_BASE_FILE_NAME, options) {
  exec %Q{java -jar "#{SELENIUM_JAR}"}
}


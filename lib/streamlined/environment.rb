def require_streamlined_plugin(plugin)
  plugin_path = File.expand_path(File.join(File.dirname(__FILE__), "../../vendor/plugins", plugin.to_s))
  $LOAD_PATH << File.join(plugin_path, "lib")
  require File.join(plugin_path, "init.rb")
end

# Streamlined depends on classic pagination, so we just require the plugin itself
# to avoid deprecation warnings in 1.2.x or errors in 2.x.
require_streamlined_plugin(:classic_pagination)

require 'rubygems'
require 'logger'
files = %w(core_extensions config loader multi_rails_error)
files.each do |file|
  require File.expand_path(File.join(File.dirname(__FILE__), "multi_rails/#{file}"))
end

module MultiRails
  VERSION = '0.0.2'
  
  def self.gem_and_require_rails
    Loader.gem_and_require_rails
  end
end
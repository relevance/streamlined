require 'rubygems'
require 'logger'
files = %w(core_extensions config loader multi_rails_error)
files.each do |file|
  require File.expand_path(File.join(File.dirname(__FILE__), "multi_rails/#{file}"))
end

module MultiRails
  VERSION = '0.0.1'
  
  def self.require_rails
    Loader.require_rails
  end
end
MultiRails
    by Relevance, http://thinkrelevance.com
       Rob Sanheim - MultiRails lead

== DESCRIPTION:
  
MultiRails allows easy testing against multiple versions of Rails for your Rails specific gem or plugin.

Use MultiRails to hook in Rails 2.0 testing in your continuous integration.  Still working on Rails 2.0 support?  
Use MultiRails to see where your test suite falls down against the 2.0 preview releases of Rails.

MultiRails was initially developed by members of Relevance while developing Streamlined 
against edge Rails.  To see how Streamlined uses MultiRails, go to http://trac.streamlinedframework.org.

== FEATURES:

* easily test plugins/extensions using a require from your test_helper.rb and a require in your RakeFile
* rake tasks to test against a specific version of Rails, or all versions of Rails available locally as Gems

== TODOs:

* enable multi_rails testing in a plain ol' Rails app -- this is difficult right now because of the Rails boot process
* improve docs on how to override what files are required by multi_rails
* test against Rails versions that are just checked out, and not installed via Gems

== REQUIREMENTS:

* Ruby 1.8.5 or higher
* Rubygems
* Rails 1.2.1 or higher
* at least one copy of Rails installed via rubygems.

== INSTALLING FOR PLUGINS

NOTE - for multi_rails to work at all, you *must* remove any of your own requires of the Rails
       framework in any sort of test_helper you have.  MultiRails handles requiring Rails on its own,
       immediately after it uses gem to activate the correct version under test.
       
* sudo gem install multi_rails
    
* in your projects Rakefile, require a simple rb file which just loads the multi_rails rake tasks.

  require "load_multi_rails_rake_tasks"
  
* run rake -T in your root, verify that you see two new rake tasks.

  rake test:multi_rails:all
  rake test:multi_rails:one
  
* In your plugins test_helper, remove any rails specific requires (activerecord, actioncontroller, activesupport, etc), 
  and require multi_rails_init instead.  

  require multi_rails_init

* Run the multi_rails:all rake task to run your test suite against all versions of Rails you have installed via gems.  Install
  other versions of Rails using rubygems to add them to your test suite.
  
* For changing the Rails version under test, set the environment variable MULTIRAILS_RAILS_VERSION to version you want, and run
  the multi_rails:one task or just run a test class directly.

== INSTALLING FOR RAILS APPS

* script/plugin install [SVN_URL here]

* run rake -T in your root, verify that you see two new rake tasks.

  rake test:multi_rails:all
  rake test:multi_rails:one
  
* add this one liner to the top of your environment.rb - we need this hook here to properly set the RAILS_GEM_VERSION before boot.rb runs

  require 'config/rails_version' if File.exists?("config/rails_version.rb")
  
* patch boot.rb because Rails used to allow beta gems to be auto loaded - this was fixed with Rails 1.2.5 (http://dev.rubyonrails.org/changeset/7832)

  rails_gem = Gem.cache.search('rails', "=#{version}.0").sort_by { |g| g.version.version }.last
  

== HELP

* Are you trying to use MultiRails in a plain rails application?  Right now there isn't a good way to do this, without hacking
  up your boot.rb.  If you have any ideas please do contribute.
  
* Getting gem activation errors?  Are you sure you removed your rails requires and are just using multi rails?
  
* Join the mailing list!  
  http://groups.google.com/group/multi_rails
  multi_rails@googlegroups.com
  

== LICENSE:

(The MIT License)

Copyright (c) 2007 Relevance, http://thinkrelevance.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

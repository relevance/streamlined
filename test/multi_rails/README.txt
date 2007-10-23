MultiRails
    by Relevance, http://thinkrelevance.com

== DESCRIPTION:
  
MultiRails easily allows testing against multiple versions of Rails.

MultiRails was initially developed by members of Relevance while developing Streamlined 
against edge Rails.  To see how Streamlined uses MultiRails, go to http://streamlinedframework.org.

== FEATURES/PROBLEMS:

* easily test plugins/extensions to Rails using a one line require from your test_helper.rb
* rake tasks to test against a specific version of Rails, or all versions of Rails available locally as Gems

== TODOs:

* enable multi_rails testing in a plain ole' Rails app -- this is difficult right now because of the Rails boot process

== REQUIREMENTS:

* Ruby 1.8.5 or higher
* Rubygems
* Rails 1.2.1 or higher
* at least one copy of Rails installed via rubygems.

== INSTALL:

* sudo gem install multi_rails
* in your test_helper.rb, require the multi_rails init file -- your specific path may differ
    require File.expand_path(File.join(File.dirname(__FILE__), "/multi_rails/init"))
* IMPORTANT: you _must_ require multi_rails before you require any Rails files


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

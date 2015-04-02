## Description
Rake-based dev env for Haskell

## Installation
<pre>
    $ gem install bundler
    $ bundle install
    $ bundle exec rake dev:init
</pre>

## Rakefile Targets/Commands
<pre>
    $ alias rake='bundle exec rake'
    $ rake -T
    $ rake dev:start[src]
</pre>

## Docker Notes
Some docker files require manual edits. Said files contain "REPLACE[_]" in them.

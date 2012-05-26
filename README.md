Installation
------------
`gem install rack-colorized_logger`

or in `Gemfile`:

`gem 'rack-colorized_logger', :group => :development`

Config
------

it would like a hash of keys that are `Symbol` or `String` of valid methods
to call on the `Rack::Request` object. the method should return a `Hash`-like
object. for customization purposes, the key can be a `Proc` that returns an
array where the first element is the name to display, and the second is the
data to display.

###default:

```ruby
DEFAULT_COLORS = {
  :params =>  [:blue, :red],
  :session => [:cyan, :yellow],
  :cookies => [:green, :magenta]
}
```

###2 ways to customize:

 * pass block to constructor
 * set `Rack::ColorizedLogger::CONFIG`

Examples
--------

###default:

```ruby
require 'sinatra'
require 'rack-colorized_logger'

configure do
  use Rack::ColorizedLogger
end
```

###default in rails:

config/environments/development.rb:
```ruby
YourRailsApp::Application.configure do |config|
  ...
  config.middleware.use Rack::ColorizedLogger
  ...
end
```

####NOTE differences if `Rails` is `defined?`
 * `@path` defaults to false
 * `@assets` defaults to '/assets'
 * `@public` defaults to `::File.join Rails.root, 'public'`

###custom:

```ruby
require 'sinatra'
require 'rack-colorized_logger'

configure do
  use Rack::ColorizedLogger do |logger|

    # setting the output and colors via block
    logger.colors = {

      # keep params as default
      :params => [:blue, :red],

      # parse a JSON body and log it
      lambda {|r| b = JSON.parse(r.body.read); r.body.rewind; return ['body', b] } => [:green, :magenta],

      # display all request.env that has printable values
      lambda {|r| return ['env', r.env.select {|k,v| v.is_a? String}] } => [:cyan, :yellow]

    }

    # defaults to STDOUT. can be anything that `respond_to? :puts`
    logger.out = STDERR

    # if specified, builds a map of "public" files to not engage logging on requests for.
    # some web server configurations will not hit rack for "public" files.
    logger.public = 'public'

  end
end
```

###custom variant (`config.ru`):

```ruby
# default to only params and cookies
Rack::ColorizedLogger::COLORS = {
  :params =>  [:blue, :red],
  :cookies => [:green, :magenta]
}

class FooApp < Sinatra::Base
  # uses default above
  use Rack::ColorizedLogger
  get('/'){ 'foo' }
end

class BazApp < Sinatra::Base
  # only shows params
  use Rack::ColorizedLogger do |l|
    l.colors = {:params => [:blue, :red]}
    l.path = false
    l.assets = '/some/asset/path'
  end
  get('/'){ 'baz' }
end

class BarApp < Sinatra::Base
  # uses defaults above again
  use Rack::ColorizedLogger
  get('/'){ 'bar' }
end

map('/foo'){ run FooApp }
map('/baz'){ run BazApp }
map('/bar'){ run BarApp }
```

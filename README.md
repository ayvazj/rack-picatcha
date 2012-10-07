Dropin replacement for rack-recaptcha that uses picatcha verification.

## How to Use

### Configuration

First, install the library with:
    [sudo] gem install rack-picatcha

You have to require 'rack-picatcha' in your gemfile.

````ruby
## Gemfile
gem 'rack-picatcha', :require => 'rack/picatcha'
````


    Available options for `Rack::Picatcha` middleware are:

    * :public_key -- your Picatcha API public key *(required)*
    * :private_key -- your Picatcha API private key *(required)*
    * :proxy_host -- the HTTP Proxy hostname *(optional)*
    * :proxy_port -- the HTTP Proxy port *(optional)*
    * :proxy_user -- the HTTP Proxy user *(optional, omit unless the proxy requires it)*
    * :proxy_password -- the HTTP Proxy password *(optional, omit unless the proxy requires it)*

Now configure your app to use the middleware. This might be different across each web framework.
Only tested with Sinatra

#### Sinatra

````ruby
## app.rb
use Rack::Picatcha, :public_key => 'KEY', :private_key => 'SECRET'
helpers Rack::Picatcha::Helpers
````

#### Padrino

````ruby
## app/app.rb
use Rack::Picatcha, :public_key => 'KEY', :private_key => 'SECRET'
helpers Rack::Picatcha::Helpers
````


#### Rails

````ruby
## application.rb:
module YourRailsAppName
  class Application < Rails::Application
    ...
    config.gem 'rack-picatcha', :lib => 'rack/picatcha'
    config.middleware.use Rack::Picatcha, :public_key => 'KEY', :private_key => 'SECRET'
  end
end

## application_helper.rb or whatever helper you want it in.
module ApplicationHelper
  include Rack::Picatcha::Helpers
end

## application_controller.rb or whatever controller you want it in.
class ApplicationController < ActionController::Base
  ...
  include Rack::Picatcha::Helpers
  ...
end
````

### Helpers

The `Rack::Picatcha::Helpers` module (for Sinatra, Rails, Padrino) adds these methods to your app:

Return a picatcha form
```ruby
  picatcha_tag  :challenge, :public_key => PUBLIC_KEY
```

To test whether or not the verification passed, you can use:

```ruby
  picatcha_valid?
```

or
 
```ruby
  picatcha_valid? :picatcha => params[:picatcha], :private_key => "#{recaptcha_privatekey}"
```

The `picatcha_valid?` helper can also be overloaded during tests. You
can set its response to either true or false by doing the following:

```ruby
 # Have picatcha_valid? return true
 Rack::Picatcha.test_mode!

 # Or have it return false
 Rack::Picatcha.test_mode! :return => false
```


### Contributors

James Ayvaz - [ayvazj](https://github.com/ayvazj)

  * drop in replacement for rack-recaptcha

#### Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

#### Copyright

Copyright (c) 2012 James Ayvaz. See LICENSE for details.

# Chillout

[![Build Status](https://travis-ci.org/chilloutio/chillout.png)](https://travis-ci.org/chilloutio/chillout)
[![Code Climate](https://codeclimate.com/github/chilloutio/chillout.png)](https://codeclimate.com/github/chilloutio/chillout)
[![Gem Version](https://badge.fury.io/rb/chillout.png)](http://badge.fury.io/rb/chillout)

Chillout gem tracks your ActiveRecord models statistics. Every morning you get report how your Rails app performed. Please visit [chillout.io](http:chillout.io) for more details.

## Installation

Add this line to your Rails application's Gemfile:

    gem 'chillout'

And then execute:

    $ bundle

And add following line to config/environments/production.rb with your own SECRET_KEY:

    ```ruby
    config.chillout = { :secret => 'SECRET_KEY' }
    ```

And that's all!

Check if everything is ok:

    $ RAILS_ENV=production rake chillout:check

You'll see "Chillout API available" if everything is ok. Otherwise you'll be informed about problem with authorization (maybe you've put wrong secret?) or not known problems, like invalid values in configuration.

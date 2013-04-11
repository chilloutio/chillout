# Chillout

[![Build Status](https://travis-ci.org/chilloutio/chillout.png)](https://travis-ci.org/chilloutio/chillout)
[![Code Climate](https://codeclimate.com/github/chilloutio/chillout.png)](https://codeclimate.com/github/chilloutio/chillout)
[![Gem Version](https://badge.fury.io/rb/chillout.png)](http://badge.fury.io/rb/chillout)

## Installation

Add this line to your Rails application's Gemfile:

    gem 'chillout'

And then execute:

    $ bundle

And run Rails generator:

    $ rails g chillout:install EMAIL EMAIL2...

And that's all! You can find whole configuration in config/environments/production.rb under ```chillout``` key.

Check if everything is ok:

    $ RAILS_ENV=production rake chillout:check

You'll see "Chillout API available" if everything is ok. Otherwise you'll be informed about problem with authorization (maybe you've put wrong secret?) or not known problems, like invalid values in configuration.

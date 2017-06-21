# Chillout

[![Build Status](https://travis-ci.org/chilloutio/chillout.png)](https://travis-ci.org/chilloutio/chillout)
[![Code Climate](https://codeclimate.com/github/chilloutio/chillout.png)](https://codeclimate.com/github/chilloutio/chillout)
[![Gem Version](https://badge.fury.io/rb/chillout.png)](http://badge.fury.io/rb/chillout)

Chillout gem tracks your ActiveRecord models statistics. You can see the metrics for your application in a grafana dashboard. Please visit [get.chillout.io](http://get.chillout.io/) for more details.

## Installation

Add this line to your Rails application's `Gemfile`:

    gem 'chillout'

And then execute:

    $ bundle

And add following line to `config/environments/production.rb` with your own `SECRET_KEY`:

    config.chillout = { secret: 'SECRET_KEY' }

And that's all!

## Usage

chillout gem is automatically tracking your model creations. Remember you have to be in `production` environment - otherwise chillout gem will NOT track your metrics.

### Custom metrics

You can use `Chillout::Metric.track('custom_name')` to track a custom, phony metric. It's quite useful when you want to track a certain business process, like:

```
# in 'new':
Chillout::Metric.track('RegistrationStarted')

# in 'create':
Chillout::Metric.track('RegistrationCompleted')
```

We encourage you to ship your own class (Adapter) which encapsulates this global constant and it's closer to your application's domain.

## Compatibility

Chillout gem is tested using Travis CI. You can [check it](https://travis-ci.org/chilloutio/chillout) to get insight about which versions of Rails and Rubies are actually supported. We provide listeners for ActiveRecord and Mongoid::Document persistance layers.

## Development

Running complete test suite:

    bundle install
    bundle exec rake bundle
    bundle exec rake test

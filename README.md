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

You can use `Chillout::Metric.track('custom_name')` to track a custom metric. It's quite useful when you want to track a certain business process, like:

```ruby
# in 'new':
Chillout::Metric.track('RegistrationStarted')

# in 'create':
Chillout::Metric.track('RegistrationCompleted')
```

We encourage you to ship your own class (Adapter) which encapsulates this global constant and it's closer to your application's domain.

### Advanced custom metrics

For more advanced tracking which supports multiple values, multiple tags and custom timestamps use `Chillout::Metric.push`:

```ruby
Chillout::Metric.push(
  series: "purchases",
  tags: {
    country: "USA",
    terminal: "KATE-123",
  },
  timestamp: Time.now.utc,
  values: {
    number_of_products: 4,
    total_amount: 55.70,
    tax: 5.70,
  },
)
```

* `tags`, `timestamp` and `values` are optional.
* Tag keys and values should be strings (or symbols).
* Make sure that given values types are consistent. Avoid sending `total_amount: 55.70` in one metric and `total_amount: 60` in another. Always convert to same class such as Float, Integer or String.

## Different strategy

By default chillout uses a background thread to send metrics in a non-blocking way. However, if you prefer it can use `active_job` and the adapter you configured for it ie. sidekiq, resque, delayed_job, etc.

```ruby
config.chillout = {secret: 'secret', strategy: :active_job}
```

This feature is available since Rails 4.2

## Compatibility

Chillout gem is tested using Travis CI. You can [check it](https://travis-ci.org/chilloutio/chillout) to get insight about which versions of Rails and Rubies are actually supported. We provide listeners for ActiveRecord.

## Development

Running complete test suite:

    bundle install
    bundle exec rake bundle
    bundle exec rake test

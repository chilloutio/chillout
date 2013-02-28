# Chillout

## Installation

Add this line to your Rails application's Gemfile:

    gem 'chillout'

And then execute:

    $ bundle

And configure in config/environments/production.rb:

```ruby
config.chillout = {
  secret: '<YOUR_SECRET>',
  ssl: true,
  port: 443,
  hostname: 'api.chillout.io'
}
```

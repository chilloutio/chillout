require 'active_record'

ActiveRecord::Migration.verbose = false
load File.expand_path('../../db/schema.rb', File.dirname(__FILE__))

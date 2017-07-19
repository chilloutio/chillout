require 'test_helper'
require 'chillout/creation_listener'
require 'chillout/listener_injector'
require 'active_record'
require 'logger'
require 'minitest/stub_const'

module Chillout
  class WorkerIntegrationTest < ChilloutTestCase

    def setup
      ActiveRecord::Base.establish_connection(
        :adapter  => 'sqlite3',
        :database => 'database.sqlite',
      )
      ActiveRecord::Migration.verbose = false
      load 'test/support/rails_5_1_1/db/schema.rb'
      i = ListenerInjector.new
      i.logger = Logger.new(STDOUT)
      i.inject!

      workaround = Class.new(ActiveRecord::Base)
      def workaround.name
        "Kaboom"
      end
      klass = Class.new(workaround)
      klass.table_name = "entities"
      Object.const_set(:Kaboom, klass)
      klass.has_and_belongs_to_many :followers,
        class_name: "Kaboom",
        join_table: "entities_following_entities",
        foreign_key: "follower_id",
        association_foreign_key: "target_id"
    end

    def teardown
      Chillout.creations = nil
    end

    module PseudoRails
      def self.logger
        Logger.new(STDOUT)
      end
    end

    def test_no_exception_for_hbtm_anonymous_classes
      Object.stub_const(:Rails, PseudoRails) do
        k = Kaboom.create!(name: Time.current.to_s, state: "parked")
        k.follower_ids=[1]
      end
      assert_equal 1, Chillout.creations[:Kaboom]
      assert_equal 1, Chillout.creations.size
    end
  end
end
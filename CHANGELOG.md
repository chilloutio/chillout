# chillout gem changes

Unreleased
----------

- Introduced sidekiq jobs monitoring.


0.8.6
-----

- Introduced custom advanced metrics.

0.8.5
-----

- Bugfix: Duration metrics are always sent as floats.

0.8.4
-----

- Bugfix for [Custom metrics are not sent after 1st request](https://github.com/chilloutio/chillout/issues/4)

0.8.3
-----

- Introduced ActionController performance tracking.
- Added ability to disabled automatic ActiveRecord creations tracking by passing `creations_tracking: false` via config.
- Added ability to disabled automatic ActionController performance tracking by passing `requests_tracking: false` via config.

0.8.2
-----

- Fixed chillout logging to not `#flush` which caused minor errors.

0.8.1
-----

- Fixed chillout logging to not `#flush` which caused minor errors.

0.8.0
-----

- Introduce `active_job` strategy for sending metrics to chillout servers
- Add `sidekiq` integration. Metrics collected when processing sidekiq jobs are sent to the server
- Support for Mongoid removed.

0.7.0 (never released)
----------------------

- Support for custom metrics
- Support for Mongoid
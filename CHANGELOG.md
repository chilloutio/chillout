# chillout gem changes

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
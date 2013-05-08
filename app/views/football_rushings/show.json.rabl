object @rushing
attribute :attempts, :yards, :td, :fumbles, :fumbles_lost
node(:id) { |r| r.id.to_s }
node(:average) { |r| number_with_precision(r.average, precision: 2) }
object @gamelog
node(:id) { |o| o.id.to_s }
attributes :period, :time, :logentry, :score

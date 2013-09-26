object @bbstats
node(:id) { |o| o.id.to_s }
node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
attributes :twoattempt, :twomade, :threeattempt, :threemade, :ftmade, :ftattempt, :fouls, :assists, :steals, :blocks, :offrebound, :defrebound

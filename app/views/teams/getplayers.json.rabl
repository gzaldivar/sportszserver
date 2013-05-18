object @team
attributes :fb_pass_players, :if => lambda { |m| !m.fb_pass_players.nil? }
attributes :fb_rush_players, :if => lambda { |m| !m.fb_rush_players.nil? }
attributes :fb_rec_players, :if => lambda { |m| !m.fb_rec_players.nil? }
attributes :fb_def_players, :if => lambda { |m| !m.fb_def_players.nil? }
attributes :fb_spec_players, :if => lambda { |m| !m.fb_spec_players.nil? }
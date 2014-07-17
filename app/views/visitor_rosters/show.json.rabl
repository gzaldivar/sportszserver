object @visitor_roster
node(:id) { |o| o.id.to_s }
node(:visiting_team_id) { |v| v.visiting_team_id.to_s }
attributes :number, :lastname, :firstname, :number, :position, :logname
node(:numberlogname) { |v| v.numlogname }

if @sport.name == "Lacrosse"
	child :lacrosstat, :object_root => false do
		node(:lacrosstat_id) { |l| l.id.to_s }
		node(:athlete_id) { |a| a.athlete_id.to_s }
		node(:lacross_game_id) { |g| g.lacross_game_id.to_s }
		node(:visitor_roster_id) { |v| v.visitor_roster_id.to_s }

		child :lacross_scorings, :object_root => false do
			node(:lacross_scoring_id) { |s| s.id.to_s }
			node(:lacrosstat_id) { |l| l.lacrosstat.id.to_s }
			node(:athlete_id) { |l| l.lacrosstat.athlete_id.to_s }
			node(:visitor_roster_id) { |l| l.lacrosstat.visitor_roster_id.to_s}
			attributes :gametime, :scorecode, :period
			node :assist, :if => lambda { |a| !a.assist.nil? } do |g|
				g.assist
			end
		end

		child :lacross_player_stats, :object_root => false do
			node(:lacross_player_stat_id) { |s| s.id.to_s }
			node(:lacrosstat_id) { |l| l.lacrosstat.id.to_s }
			node(:athlete_id) { |l| l.lacrosstat.athlete_id.to_s }
			node(:visitor_roster_id) { |l| l.lacrosstat.visitor_roster_id.to_s}
			attributes :shot, :face_off_won, :face_off_lost, :face_off_violation, :ground_ball, :interception, :turnover, :caused_turnover, :steals, :period
		end

		child :lacross_penalties, :object_root => false do
			node(:lacross_penalty_id) { |s| s.id.to_s }
			node(:lacrosstat_id) { |l| l.lacrosstat.id.to_s }
			node(:athlete_id) { |l| l.lacrosstat.athlete_id.to_s }
			node(:visitor_roster_id) { |l| l.lacrosstat.visitor_roster_id.to_s}
			attributes :infraction, :type, :gametime, :type, :period
		end

		child :lacross_goalstats, :object_root => false do
			node(:lacross_goalstat_id) { |g| g.id.to_s }
			node(:lacrosstat_id) { |l| l.lacrosstat.id.to_s }
			node(:athlete_id) { |l| l.lacrosstat.athlete_id.to_s }
			node(:visitor_roster_id) { |l| l.lacrosstat.visitor_roster_id.to_s}
			attributes :saves, :minutesplayed, :goals_allowed, :period
		end
	end
elsif @sport.name == "Soccer"
	child :soccer_stats, :object_root => false do
		node(:soccer_stat_id) { |s| s.id.to_s }
		node(:soccer_game_id) { |s| s.soccer_game_id.to_s }
		node(:athlete_id) { |a| a.athlete_id.to_s }
		node(:visitor_roster) { |v| v.visitor_roster_id.to_s }

		child :soccer_playerstats, :object_root => false do
			node(:soccer_playerstat_id) { |s| s.id.to_s }
			node(:athlete_id) { |l| l.soccer_stat.athlete_id.to_s }
			node(:visitor_roster_id) { |v| v.soccer_stat.visitor_roster_id.to_s }
			attributes :shots, :cornerkick, :steals, :fouls, :period
		end

		child :soccer_scorings, :object_root => false do
			node(:soccer_scoring_id) { |s| s.id.to_s }
			node(:athlete_id) { |l| l.soccer_stat.athlete_id.to_s }
			node(:visitor_roster_id) { |v| v.soccer_stat.visitor_roster_id.to_s }
			attributes :gametime, :period

			node :assist, :if => lambda { |a| !a.assist.nil? } do |g|
				g.assist
			end

			child :photos, :object_root => false do |p|
				node(:id) { |p| p.id.to_s }
				attributes :displayname
			end
			
			child :videoclips, :object_root => false do |p|
				node(:id) { |p| p.id.to_s }
				attributes :displayname
			end
		end

		child :soccer_penalties, :object_root => false do
			node(:soccer_penalty_id) { |s| s.id.to_s }
			node(:athlete_id) { |l| l.soccer_stat.athlete_id.to_s }
			node(:visitor_roster_id) { |v| v.soccer_stat.visitor_roster_id.to_s }
			attributes :infraction, :card, :gametime, :period
		end

		child :soccer_goalstats, :object_root => false do
			node(:soccer_goalstat_id) { |s| s.id.to_s }
			node(:athlete_id) { |l| l.soccer_stat.athlete_id.to_s }
			node(:visitor_roster_id) { |v| v.soccer_stat.visitor_roster_id.to_s }
			attributes :saves, :goals_allowed, :minutes_played, :period
		end
	end
end

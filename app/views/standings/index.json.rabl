collection @gamerecords
attribute :teamname, :mascot, :leaguewins, :leaguelosses, :nonleaguewins, :nonleaguelosses, :sportid, :oppimageurl, :teamid
node(:gameschedule_id) { |g| g.gameschedule_id.to_s }
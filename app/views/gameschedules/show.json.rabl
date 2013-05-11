object @gameschedule
node(:id) { |o| o.id.to_s }
node(:opponentpic) { |t| t.opponentpic(:tiny) }
attributes :date, :startdate, :location, :opponent, :event, :homeaway, :starttime, :game_name, :homeq1, :homeq2, :homeq3, 
		   :homeq4, :opponentq1, :opponentq2, :opponentq3, :opponentq4, :penalty, :firstdowns, :penaltyyards
if !@gamelogs.nil?
	child @gamelogs => :gamelogs do
		attribute :period, :logentry, :time, :score
		node(:id) { |o| o.id.to_s }
	end
end
if !@stats.nil?
	extends 'gameschedules/stats'
end

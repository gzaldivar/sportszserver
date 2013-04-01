object @gameschedule
node(:id) { |o| o.id.to_s }
attributes :date, :startdate, :location, :opponent, :event, :homeaway, :starttime, :game_name, :homeq1, :homeq2, :homeq3, 
		   :homeq4, :opponentq1, :opponentq2, :opponentq3, :opponentq4
child :gamelogs do
	node(:id) { |o| o.id.to_s }
	attribute :logentry, :period, :time, :score
end
if !@stats.nil?
	extends 'gameschedules/stats'
end
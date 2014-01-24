node(:totalfirstdowns) { totalfirstdowns(@sport, @gameschedule) }
node(:totalyards) { @footballtotalyards }
node(:passingtotalyards) { @passingtotalyards }
node(:rushingtotalyards) { @rushingtotalyards }
node(:penalties) { @gameschedule.penalty }
node(:pealtyyards) { @gameschedule.penaltyyards }
node(:turnovers) { @turnovers }
require 'spec_helper'

describe Gameschedule do

    before(:each) do
	    @sport = {
	      :name => "Football",
	      :year => "2013",
	      season: "Fall",
	      :sex => "Male",
	      mascot: "Tigers"
	    }
	    @team = {
	      title: "My Team",
	      mascot: "foobar"
	    }
	    @schedule = {
	      starttime: DateTime.now,
	      gamedate: DateTime.now,
	      location: "Mission Viejo",
	      opponent: "Orange",
	      event: "Tigers",
	      homeaway: "Home",
	      live: "live", 
	      live_url: "http://www.example.com/hereitis"
	    }
	end

    it "should create a schedule" do
    	sport = Sport.create!(@sport)
    	team = sport.teams.create!(@team)
    	team.gameschedules.create!(@schedule)
  	end

  	it "should find all team game schedules" do
     	sport = Sport.create!(@sport)
    	team = sport.teams.create!(@team)
    	schedule = team.gameschedules.create!(@schedule)
		schedules = schedule.team 		
  	end

end

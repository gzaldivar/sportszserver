require 'spec_helper'

describe FootballPassing do
  
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
    @athlete = {
      number: 85,
      lastname: "Zaldivar",
      firstname: "Christin",
      middlename: "James",
      year: 2013,
      season: "Fall"
    }
    @fbpassing = {
      :game => "foo",
      :attempts => 10,
      :completions => 5,
      yards: 55,
      interceptions: 1,
      sacks: 1,
      yards_lost: -5
    }
	end
	
	it "should create a passing record" do
  	sport = Sport.create!(@sport)
  	athlete = sport.athletes.create!(@athlete)
    athlete.football_passings.create!(@fbpassing)
  end
  
  it "should require attempts" do
    no_attempts = FootballPassing.new(@fbpassing.merge(:attempts =>nil))
    no_attempts.should_not be_valid
  end
  
  it "should have completions" do
    comp = FootballPassing.new(@fbpassing.merge(:completions => nil))
    comp.should_not be_valid
  end
	
  it "should have yards" do
    comp = FootballPassing.new(@fbpassing.merge(:yards => nil))
    comp.should_not be_valid
  end
	
end

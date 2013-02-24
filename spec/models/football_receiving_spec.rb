require 'spec_helper'

describe FootballReceiving do
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
    @fbreceiving = {
      :game => "foo",
      :receptions => 10,
       yards: 55,
      long: 28,
      td: 1,
      fumbles: 1,
      lost: 1
    }
	end
	
	it "should create a passing record" do
  	sport = Sport.create!(@sport)
  	athlete = sport.athletes.create!(@athlete)
    athlete.football_receivings.create!(@fbreceiving)
  end
  
  it "should require receptions" do
    no_attempts = FootballReceiving.new(@fbreceiving.merge(:receptions =>nil))
    no_attempts.should_not be_valid
  end
  
  it "should have yards" do
    comp = FootballReceiving.new(@fbreceiving.merge(:yards => nil))
    comp.should_not be_valid
  end
	
  it "should have long" do
    comp = FootballReceiving.new(@fbreceiving.merge(:long => nil))
    comp.should_not be_valid
  end
end

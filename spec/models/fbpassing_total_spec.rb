require 'spec_helper'

describe Stats::FbpassingTotal do
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
    @fbtotal = {
      :attempts => 10,
      :completions => 5,
      percentage: 55.5,
      yards: 55,
      interceptions: 1,
      sacks: 1,
      yards_lost: -5
    }
  end
  
  it "should create a new passing total" do
  	sport = Sport.create!(@sport)
  	team = sport.teams.create!(@team)
  	team.fbpassing_totals.create!(@fbtotal)
  end
  
end

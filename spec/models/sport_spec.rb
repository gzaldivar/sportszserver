require 'spec_helper'

describe Sport do

    before(:each) do
	    @attr = {
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
  	end

  it "should create a new instance given a valid attribute" do
    @sport = Sport.create!(@attr)
  end

  it "should require a name" do
    no_name = Sport.new(@attr.merge(:name => ""))
    no_name.should_not be_valid
  end

  it "should require a year" do
  	no_year = Sport.new(@attr.merge(year: ""))
  	no_year.should_not be_valid
  end

  it "should require a sex" do
  	no_sex = Sport.new(@attr.merge(sex: ""))
  	no_sex.should_not be_valid
  end

   it "should require a season" do
  	no_season = Sport.new(@attr.merge(season: ""))
  	no_season.should_not be_valid
  end

  it "year should be a number" do
  	year = Sport.new(@attr.merge(year: "s123"))
  	year.should_not be_valid
  	year = Sport.new(@attr.merge(year: "2013"))
  	year.should be_valid
  end

  it "sex should be" do
  	sex = Sport.new(@attr.merge(sex: "foo"))
  	sex.should_not be_valid
  	sex = Sport.new(@attr.merge(sex: "Male"))
  	sex.should be_valid
  	sex = Sport.new(@attr.merge(sex: "Female"))
  	sex.should be_valid
  end

  it "should require a team name" do
    team = Team.new(@team.merge(title: ""))
    team.should_not be_valid
  end

  it "should require a team mascot" do
    team = Team.new(@team.merge(mascot: ""))
    team.should_not be_valid
  end

  it "should add a team to the sport" do
    @sport = Sport.create!(@attr)
    team = @sport.teams.create!(@team)
  end
	
end

require 'spec_helper'

describe Team do

    before(:each) do
      @sport = {
        :name => "Football",
        :year => "2013",
        season: "Fall",
        :sex => "Male",
        mascot: "Tigers"
      }
	    @attr = {
	      :title => "Varsity",
	      :mascot => "Tigers",
	    }
  	end

  it "should create a new instance given a valid attribute" do
    sport = Sport.create!(@sport)
    sport.teams.create!(@attr)
  end

  it "should have a title" do
  	title = Team.new(@attr.merge(title: ""))
  	title.should_not be_valid
  end

  it "should have a mascot" do
   	mascot = Team.new(@attr.merge(mascot: ""))
  	mascot.should_not be_valid
  end
	
end

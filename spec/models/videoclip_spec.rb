require 'spec_helper'

describe Videoclip do
    before(:each) do
      @sport = {
        :name => "Football",
        :year => "2013",
        season: "Fall",
        :sex => "Male",
        mascot: "Tigers"
      }
	    @attr = {
	      :filename => "foo.mp4",
	    }
  	end

  it "should create a new instance given a valid attribute" do
    sport = Sport.create!(@sport)
    sport.videoclips.create!(@attr)
  end

  it "should have a filename" do
  	title = Videoclip.new(@attr.merge(filename: ""))
  	title.should_not be_valid
  end
	
end

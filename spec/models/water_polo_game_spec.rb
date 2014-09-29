require 'spec_helper'

describe WaterPoloGame do
    before(:each) do
      @sport = Sport.new(
        :name => "Water Polo",
        :year => "2014",
        season: "Fall",
        :sex => "Male",
        mascot: "Tigers",
        sitename: "Rancho Santa Margarita",
        sportname: "Water Polo",
        cssstyle: "application",
        bannerpos: "right",
        enable_user_pics: true,
        enable_user_video: true)

      @team = @sport.teams.new(title: "My Team",  mascot: "Tigers")

      @schedule = @team.gameschedules.new(starttime: DateTime.now,
        gamedate: DateTime.now,
        location: "Mission Viejo",
        opponent: "Orange",
        event: "",
        homeaway: "Home",
        league: true,
        live: "live", 
        live_url: "http://www.example.com/hereitis")

      @schedule.water_polo_game = WaterPoloGame.new
      @water_polo_game = @schedule.water_polo_game
  end

  describe "initialized in before(:each)" do
    it "has 0 waterpolo_oppsog" do
      @water_polo_game.should have(0).waterpolo_oppsog
    end

    it "opposition shots on goal must not be negative" do
      @water_polo_game.waterpolo_oppsog = -1
      expect (@water_polo_game.save!).to raise_error
    end

    it "opposition saves must not be negative" do
      @water_polo_game.waterpolo_oppsaves = -1
      expect (@water_polo_game.save!).to raise_error
    end

    it "opposition assists must not be negative" do
      @water_polo_game.waterpolo_oppassists = -1
      expect (@water_polo_game.save!).to raise_error
    end

    it "opposition fouls must not be negative" do
      @water_polo_game.waterpolo_oppfouls = -1
      expect (@water_polo_game.save!).to raise_error
    end

    it "home time outs must not be negative" do
      @water_polo_game.home_time_outs_left = -1
      expect (@water_polo_game.save!).to raise_error
    end

    it "visitor time outs must not be negative" do
      @water_polo_game.visitor_time_outs_left = -1
      expect (@water_polo_game.save!).to raise_error
    end

    it "visitor period one score should not be negative" do
      @water_polo_game.visitor_score_period1 = -1
      expect (@water_polo_game.save!).to raise_error
    end

  end

end

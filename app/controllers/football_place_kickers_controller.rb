class FootballPlaceKickersController < ApplicationController
	include FootballStatistics
	
	before_filter	:authenticate_user!
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:update, :destroy]
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
	    controller.SiteOwner?(@athlete.team_id)
	end
#	before_filter do |check|
#		check.packageEnabled?(current_site)
#	end

  	def new
		@placekicker = FootballPlaceKicker.new(gameschedule_id: params[:gameschedule_id])
		@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(params[:gameschedule_id].to_s)

		if params[:livestats] == "Play by Play"
			@live = "Play by Play"
		elsif params[:livestats] == "Totals"
			@live = "Totals"
		end
	end

	def create
		begin
			if params[:football_place_kicker].nil?
				game = Gameschedule.find(params[:gameschedule_id].to_s)
				live = params[:livestats].to_s
			else
				game = Gameschedule.find(params[:football_place_kicker][:gameschedule_id].to_s)
				live = params[:football_place_kicker][:livestats].to_s
			end

			if live == "Totals"
				placekicker = @athlete.football_place_kickers.create!(params[:football_place_kicker])
			else
				placekicker = @athlete.football_place_kickers.new(gameschedule_id: game.id.to_s)

				if params[:fgmissed] or params[:fgmade] or params[:fgblocked] or params[:xpmade] or params[:xpmissed] or params[:xpblocked]
					livestats(placekicker, @athlete, params, game)
				else
					raise "Please check Made, Missed or Blocked!"
				end
			end

			respond_to do |format|
		        format.html { redirect_to footballspecialteamstats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: game.team_id, 
		        								id: game.id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { placekicker: placekicker } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football place kicker stats "	+ e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def update
		begin
			if params[:football_place_kicker].nil?
				live = params[:livestats].to_s
			else
				live = params[:football_place_kicker][:livestats].to_s
			end

			if live == "Totals"
				@placekicker.update_attributes!(params[:football_place_kicker])
			elsif live == "Adjust"
				adjust(@placekicker, @athlete, params)
			else
				if params[:fgmissed] or params[:fgmade] or params[:fgblocked] or params[:xpmade] or params[:xpmissed] or params[:xpblocked]
					livestats(@placekicker, @athlete, params, @gameschedule)
				else
					raise "Please check Made, Missed or Blocked!"
				end
			end

			respond_to do |format|
		        format.html { redirect_to footballspecialteamstats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: @gameschedule.team_id, 
		        								id: @gameschedule.id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { placekicker: @placekicker } }
		     end		
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating place kicker stats " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def index
		fbstats = Placekickerstats.new(@sport, @athlete)
		@stats = fbstats.stats
		@totals = fbstats.placekickertotals
	end

	def show
		if params[:stat_id]
			@placekicker = FootballPlaceKicker.find(params[:stat_id])
		else
			@placekicker = FootballPlaceKicker.new(athlete_id: @athlete.id, gameschedule_id: params[:gameschedule_id])
		end
		@gameschedule = Gameschedule.find(@placekicker.gameschedule_id)
	end

	def destroy
		begin
			@placekicker.destroy
			respond_to do |format|
				format.html { redirect_to sport_athlete_path(@sport, @athlete) }
				format.json { render status: 200, json: { message: "Success" } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to sport_athlete_path(@sport, @athlete), alert: e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

		def correct_stat
			@placekicker = @athlete.football_place_kickers.find(params[:id])
			@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(@placekicker.gameschedule_id)
		end

		def livestats(stat, athlete, params, game)
			if params[:fgmissed].to_i > 0 or params[:fgblocked].to_i > 0 or params[:fgmade].to_i > 0
				stat.fgattempts = stat.fgattempts + 1
			end
			if params[:fgblocked].to_i > 0
				stat.fgblocked = stat.fgblocked + 1
			end
			if params[:fglong].to_i > stat.fglong
				stat.fglong = params[:fglong].to_i
			end

			if params[:xpmade].to_i > 0 or params[:xpmissed].to_i > 0 or params[:xpblocked].to_i > 0
				stat.xpattempts = stat.xpattempts + 1
			end
			if params[:xpmissed].to_i > 0
				stat.xpmissed = stat.xpmissed + 1
			end
			if params[:xpblocked].to_i > 0
				stat.xpblocked = stat.xpblocked + 1
			end

			if params[:fgmade].to_i > 0
				stat.fgmade = stat.fgmade + 1
			elsif params[:xpmade].to_i > 0
				stat.xpmade = stat.xpmade + 1
			end

			stat.save!

			if params[:fgmade].to_i > 0

				if !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
					gamelog = game.gamelogs.new(period: params[:quarter], time: params[:time], football_place_kicker_id: stat.id, 
												logentry: @athlete.logname, yards: params[:fglong], score: "FG")
					gamelog.save!
					if params[:quarter]
						case params[:quarter]
						when "Q1"
							game.homeq1 = game.homeq1 + 3
						when "Q2"
							game.homeq2 = game.homeq2 + 3
						when "Q3"
							game.homeq3 = game.homeq3 + 3
						when "Q4"
							game.homeq4 = game.homeq4 + 3
						end
						game.save!
					end
				end
			elsif params[:xpmade].to_i > 0

				if !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
					gamelog = game.gamelogs.new(period: params[:quarter], time: params[:time], football_place_kicker_id: stat.id,
												logentry: @athlete.logname, score: "XP")
					gamelog.save!
					if params[:quarter]
						case params[:quarter]
						when "Q1"
							game.homeq1 = game.homeq1 + 1
						when "Q2"
							game.homeq2 = game.homeq2 + 1
						when "Q3"
							game.homeq3 = game.homeq3 + 1
						when "Q4"
							game.homeq4 = game.homeq4 + 1
						end
						game.save!
					end
				end
			end
		end

		def adjust(stat, athlete, params)
			if params[:fgmissed].to_i > 0 and stat.fgattempts > stat.fgmade
				stat.fgattempts -= 1
			elsif params[:fgmissed].to_i > 0
				raise "FG attempts equal FG made. Adjust stats by removing a game log entry or use the totals form."
			end

			if params[:fgblocked].to_i > 0 and stat.fgblocked > params[:fgblocked]
				stat.fgblocked -= 1
			end

			if params[:fglong].to_i > 0
				stat.fglong -= params[:fglong].to_i
			end

			if params[:xpmissed].to_i > 0 and stat.xpattempts > stat.xpmade
				stat.xpattempts -= 1
			elsif params[:xpmissed].to_i > 0
				raise "XP attempts equal XP made. Adjust stats by removing a game log entry or use the totals form."
			end

			if params[:xpblocked].to_i > 0
				stat.xpblocked -= 1
			end

			stat.save!
		end
end

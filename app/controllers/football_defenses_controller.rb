class FootballDefensesController < ApplicationController
	include FootballStatistics

	before_filter	:authenticate_user!
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:edit, :update, :destroy]
	before_filter 	only: [:destroy, :update, :create, :edit, :new] do |controller| 
	    controller.SiteOwner?(@athlete.team_id)
	end
#	before_filter do |check|
#		check.packageEnabled?(current_site)
#	end

	def new
		@defense = FootballDefense.new(gameschedule_id: params[:gameschedule_id])
		@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(params[:gameschedule_id].to_s)

		if params[:livestats] == "Play by Play"
			@live = "Play by Play"
		elsif params[:livestats] == "Totals"
			@live = "Totals"
		end
	end

	def create
		begin
			if params[:football_defense].nil?
				game = Gameschedule.find(params[:gameschedule_id].to_s)
				live = params[:livestats].to_s
			else
				game = Gameschedule.find(params[:football_defense][:gameschedule_id].to_s)
				live = params[:football_defense][:livestats].to_s
			end

			if live == "Totals"
				defense = @athlete.football_defenses.create!(params[:football_defense])
			else
				defense = @athlete.football_defenses.new(gameschedule_id: game.id.to_s)
				livestats(defense, @athlete, params, game)				
			end

			respond_to do |format|
		        format.html { redirect_to footballdefensestats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: game.team_id, 
		        								id: game.id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { defense: defense } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football defense stats "	+ e.message }
		        format.json { render status: 404, json: { error: e.message } }
		     end			
		end
	end

	def show
		if params[:stat_id]
			@defense = FootballDefense.find(params[:stat_id])
		else
			@defense = FootballDefense.new(athlete_id: @athlete.id, gameschedule_id: params[:gameschedule_id])
		end
		@gameschedule = Gameschedule.find(@defense.gameschedule_id)
	end

	def edit		
		if params[:livestats] == "Play by Play"
			@live = "Play by Play"
		elsif params[:livestats] == "Adjust"
			@live = "Adjust"
		elsif params[:livestats] == "Totals"
			@live = "Totals"
		end
	end

	def index
		fbstats = Defensestats.new(@sport, @athlete)
		@stats = fbstats.stats
		@totals = fbstats.defensetotals
	end

	def update
		begin
			if params[:football_defense].nil?
				live = params[:livestats].to_s
			else
				live = params[:football_defense][:livestats].to_s
			end

			if live == "Totals"
				@defense.update_attributes!(params[:football_defense])
			elsif live == "Adjust"
				adjust(@defense, @athlete, params)
			else
				livestats(@defense, @athlete, params, @gameschedule)
			end

			respond_to do |format|
		        format.html { redirect_to footballdefensestats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: @gameschedule.team_id, 
		        								id: @gameschedule.id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { defense: @defense } }
		     end			
		rescue Exception => e
			respond_to do |format|
			format.html { redirect_to :back, alert: "Error updating stats for " + e.message	}
		    format.json { render status: 404, json: { error: e.message  } }
		     end			
		end
	end

	def destroy
		begin
			@defense.destroy
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
			@defense = @athlete.football_defenses.find(params[:id])
			@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(@defense.gameschedule_id)
		end
		
		def livestats(stat, athlete, params, game)
			if params[:tackles].to_i > 0
				stat.tackles = stat.tackles + params[:tackles].to_i
				game.lastplay = athlete.logname + " - Tackle"
			end

			stat.int_yards = stat.int_yards + params[:int_yards].to_i

			if params[:assists].to_i
				stat.assists = stat.assists + params[:assists].to_i
				game.lastplay = athlete.logname + " - Tackle Assist"
			end

			if params[:sackassist].to_i
				stat.sackassist += params[:sackassits].to_i
				game.lastplay = athlete.logname + " - Sack Assist"
			end

			if params[:sack].to_i > 0
				stat.sacks = stat.sacks + 1
				game.lastplay = athlete.logname + " - Sack"
			end

			if params[:pass_defended].to_i > 0
				stat.pass_defended = stat.pass_defended + 1
				game.lastplay = athlete.logname + " - Pass Defended"
			end

			if params[:int_yards].to_i > stat.int_long
				stat.int_long = params[:int_yards]
			end

			if params[:int].to_i > 0
				stat.interceptions = stat.interceptions + 1
				game.lastplay = athlete.logname + " - Interception"

				if params[:int_yards].to_i > 0
					game.lastplay = game.lastplay + " return - " + params[:int_yards]
				end
			end

			if params[:fumbles_recovered].to_i > 0
				stat.fumbles_recovered = stat.fumbles_recovered + 1
				game.lastplay = athlete.logname + " - Fumble recoverd"

				if params[:int_yards].to_i > 0
					game.lastplay = game.lastplay + " return - " + params[:int_yards]
				end
			end

			if params[:int_td].to_i > 0
				stat.int_td = stat.int_td + 1

				if !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
					if params[:int].to_i > 0
						gamelog = game.gamelogs.new(period: params[:quarter], time: params[:time], logentry: "yard interception return", 
													score: "TD", yards: params[:int_yards], football_defense_id: stat.id)
					else
						gamelog = game.gamelogs.new(period: params[:quarter], time: params[:time], logentry: "yard fumble return", 
													score: "TD", yards: params[:int_yards], football_defense_id: stat.id)
					end

					gamelog.save!
					if params[:quarter]
						case params[:quarter]
						when "Q1"
							game.homeq1 = game.homeq1 + 6
						when "Q2"
							game.homeq2 = game.homeq2 + 6
						when "Q3"
							game.homeq3 = game.homeq3 + 6
						when "Q4"
							game.homeq4 = game.homeq4 + 6
						end
					end
				end
			elsif params[:safety].to_i > 0
				stat.safety = stat.safety + 1

				if !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
					gamelog = game.gamelogs.new(period: params[:quarter], time: params[:time], logentry: "defensive safety", 
												score: "2P", yards: params[:int_yards], football_defense_id: stat.id)

					gamelog.save!
					if params[:quarter]
						case params[:quarter]
						when "Q1"
							game.homeq1 = game.homeq1 + 2
						when "Q2"
							game.homeq2 = game.homeq2 + 2
						when "Q3"
							game.homeq3 = game.homeq3 + 2
						when "Q4"
							game.homeq4 = game.homeq4 + 2
						end
					end
				end
			end

			game.save!
			stat.save!

			return stat
		end

		def adjust(stat, athlete, params)
			if params[:int].to_i > 0 and stat.interceptions > 0
				stat.interceptions -= 1
			end

			if params[:tackles].to_i > 0 and stat.tackles > 0
				stat.tackles -= 1
			end

			if params[:int_yards].to_i > 0 and stat.int_yards > 0
				stat.int_yards -= 1
			end

			if params[:assists].to_i > 0 and stat.assists > 0
				stat.assists -= 1
			end

			if params[:fumbles_recovered].to_i > 0 and stat.fumbles_recovered > 0
				stat.fumbles_recovered -= 1
			end

			if params[:sack].to_i > 0 and stat.sacks > 0
				stat.sacks -= 1
			end

			if params[:sackassits].to_i
				stat.sackassist -= 1
			end

			if params[:pass_defended].to_i > 0 and stat.pass_defended > 0
				stat.pass_defended -= 1
			end
			
			stat.save!
		end

end

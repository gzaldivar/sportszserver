class FootballDefensesController < ApplicationController
	include FootballStatistics

	before_filter	:authenticate_user!
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:show, :edit, :update, :destroy]
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
	    controller.team_manager?(@athlete, nil)
	end

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

				if current_user.score_alert? and (params[:football_defense][:int_td].to_i > 0 or params[:football_defense][:safety].to_i > 0)
					send_alert(@athlete, "Defensive score alert for ", defense, game)
				elsif current_user.stat_alert?
					send_alert(@athlete, "Defensive stat alert for ", defense, game)
				end
			else
				defense = @athlete.football_defenses.new(gameschedule_id: game.id.to_s)
				livestats(defense, @athlete, params, game)				
			end

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, defense], notice: 'Stat created for ' + @athlete.full_name }
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

				if current_user.score_alert? and (params[:football_defense][:int_td].to_i > 0 or params[:football_defense][:safety].to_i > 0)
					send_alert("Defensive score alert for ", @defense, @gameschedule)
				elsif current_user.stat_alert?
					send_alert("Defensive stat alert for ", @defense, @gameschedule)
				end
			elsif live == "Adjust"
				adjust(@defense, @athlete, params)
			else
				livestats(@defense, @athlete, params, @gameschedule)
			end

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @defense], notice: 'Stat updated for ' + @athlete.full_name }
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
		@defense.destroy
		redirect_to defense_sport_athlete_football_stats_path(@sport, @athlete)
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

		def send_alert(athlete, message, stat, game)	
	        athlete.fans.each do |user|
	            alert = stat.athlete.alerts.create!(sport: @sport, user: user, athlete: athlete.id, message: message + game.game_name, 
	                								 football_defense: stat.id, stat_football: "Defense")
	        end
		end
		
		def livestats(stat, athlete, params, game)
			stat.tackles = stat.tackles + params[:tackles].to_i
			stat.int_yards = stat.int_yards + params[:int_yards].to_i
			stat.assists = stat.assists + params[:assists].to_i
			stat.sackassist += params[:sackassits].to_i

			if params[:sack].to_i > 0
				stat.sacks = stat.sacks + 1
			end
			if params[:pass_defended].to_i > 0
				stat.pass_defended = stat.pass_defended + 1
			end
			if params[:int].to_i > 0
				stat.interceptions = stat.interceptions + 1
			end
			if params[:fumbles_recovered].to_i > 0
				stat.fumbles_recovered = stat.fumbles_recovered + 1
			end
			if params[:int_yards].to_i > stat.int_long
				stat.int_long = params[:int_yards]
			end

			if params[:int_td].to_i > 0
				stat.int_td = stat.int_td + 1
			elsif params[:safety].to_i > 0
				stat.safety = stat.safety + 1
			end

			stat.save!

			if params[:int_td].to_i > 0

				if !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
					if params[:int].to_i > 0
						gamelog = game.gamelogs.new(period: params[:quarter], time: params[:time], logentry: "yard interception return", 
													score: "TD", yards: params[:int_yards], football_defense_id: athlete.id)
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
						game.save!
					end
				end
			elsif params[:safety].to_i > 0

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
						game.save!
					end
				end
			end

			if current_user.score_alert? and (params[:int_td].to_i > 0 or params[:safety].to_i > 0)
				send_alert(athlete, "Defensive score alert for ", stat, game)
			elsif current_user.stat_alert?
				send_alert(athlete, "Defensive stat alert for ", stat, game)
			end
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

class FootballPassingsController < ApplicationController
	include FootballStatistics

	before_filter	:authenticate_user!
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:show, :edit, :update, :destroy]
	before_filter only: [:destroy, :update, :create, :edit] do |controller| 
	    controller.team_manager?(@athlete, nil)
	end

	def new
		@fbpassing = FootballPassing.new(gameschedule_id: params[:gameschedule_id])
		@game = @sport.teams.find(@athlete.team_id).gameschedules.find(params[:gameschedule_id])

		if params[:livestats] == "Play by Play"
			@live = "Play by Play"
		elsif params[:livestats] == "Totals"
			@live = "Totals"
		end
	end

	def create
		begin
			if params[:football_passing].nil?
				game = Gameschedule.find(params[:gameschedule_id].to_s)
				live = params[:livestats].to_s
			else
				game = Gameschedule.find(params[:football_passing][:gameschedule_id].to_s)
				live = params[:football_passing][:livestats].to_s
			end

			if live == "Totals"
				stats = @athlete.football_passings.create!(params[:football_passing])

				if current_user.score_alert? and (params[:football_passing][:td].to_i > 0 or params[:football_passing][:twopointconv].to_i > 0)
					send_alert(@athlete, "Passing score alert for ", stats, game)
				elsif current_user.stat_alert? and (params[:football_passing][:td].to_i == 0 or params[:football_passing][:twopointconv].to_i == 0)
					send_alert(@athlete, "Passing stat alert for ", stats, game)
				end
			else
				stats = @athlete.football_passings.new(gameschedule_id: game.id.to_s)
				livestats(stats, @athlete, params, game)				
			end

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, stats], notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { football_passing: stats } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football passing stats " + e.message }
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

	def update		
		begin
			if params[:football_passing].nil?
				live = params[:livestats].to_s
			else
				live = params[:football_passing][:livestats].to_s
			end

			if live == "Totals"
				@fbpassing.update_attributes!(params[:football_passing])

				if current_user.score_alert? and (params[:football_passing][:td].to_i > 0  or params[:football_passing][:twopointconv].to_i > 0)
					send_alert(@athlete, "Passing score alert for ", @fbpassing, @gameschedule)
				elsif current_user.stat_alert? and (params[:football_passing][:td].to_i == 0 or params[:football_passing][:twopointconv].to_i == 0)
					send_alert(@athlete, "Passing stat alert for ", @fbpassing, @gameschedule)
				end
			elsif live == "Adjust"
				adjust(@fbpassing, @athlete_id, params, @gameschedule)
			else
				livestats(@fbpassing, @athlete, params, @gameschedule)
			end

			respond_to do |format|
		        format.html { redirect_to [@sport, @athlete, @fbpassing], notice: 'Stat updated for ' + @athlete.full_name }
		        format.json { render json: { passing: @fbpassing } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error updating stats for " + @athlete.full_name + " " + e.message }
		        format.json { render status: 404, json: { error: e.message } }
		     end			
		end
	end

	def destroy
		@fbpassing.destroy
		redirect_to sport_athlete_path(@sport, @athlete)
	end

	def index
		fbstats = Passingstats.new(@sport, @athlete)
		@stats = fbstats.stats
		@totals = fbstats.passingtotals
#		@games = @sport.teams.find(@athlete.team_id).gameschedules

#		@thestats = @athlete.football_passings
#		@stats = []

#		@games.each do |g|
#			found = false
#			@thestats.each do |s|
#				if s.gameschedule_id == g.id
#					@stats << s
#					found = true
#				end
#			end
#			if !found
#				@stats << FootballPassing.new(gameschedule_id: g.id)
#			end
#		end
	end

	def adjust
		
	end

	def saveadjustment
		
	end

	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

		def correct_stat
			@fbpassing = @athlete.football_passings.find(params[:id])
			@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(@fbpassing.gameschedule_id)
		end
		
		def send_alert(athlete, message, stat, game)	
	        athlete.fans.each do |user|
	            alert = athlete.alerts.create!(sport: @sport, user: user, athlete: athlete, message: message + game.game_name, 
	                						   football_passing: stat.id, stat_football: "Passing")
	        end
		end

		def livestats(stats, athlete, params, gameschedule)
			receiver = nil
			player = nil

			stats.attempts = stats.attempts + 1
			stats.yards_lost = stats.yards_lost + params[:yards_lost].to_i
			
			if params[:sack].to_i > 0
				stats.sacks = stats.sacks + 1
			end

			if params[:int].to_i > 0
				stats.interceptions = stats.interceptions + 1
			end
						
			if params[:fd].to_i > 0
				stats.firstdowns = stats.firstdowns + 1
			end

			if params[:comp].to_i > 0
				stats.completions = stats.completions + 1
				stats.yards = stats.yards + params[:yards].to_i

				if !params[:receiver].nil? and !params[:receiver].blank?
					player = @sport.athletes.find(params[:receiver])

					if player.football_receivings.empty?
						receiver = player.football_receivings.new(receptions: 1, yards: params[:yards].to_i, longest: params[:yards].to_i,
																  gameschedule_id: gameschedule.id)
					else
						receiver = player.football_receivings.find_by(gameschedule_id: gameschedule.id)
						receiver.receptions = receiver.receptions + 1
						receiver.yards = receiver.yards + params[:yards].to_i

						if receiver.longest < params[:yards].to_i
							receiver.longest = params[:yards].to_i
						end
					end

					if params[:td].to_i > 0
						receiver.td = receiver.td + 1
					end

					if params[:rec_fumble].to_i > 0
						receiver.fumbles = receiver.fumbles + 1
					end

					if params[:rec_fumble_lost].to_i > 0
						receiver.fumbles_lost = receiver.fumbles_lost + 1
					end

					receiver.save!		
				end

				if params[:td].to_i > 0
					stats.td = stats.td + 1

					if !receiver.nil? and !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
						puts params[:quarter].to_s
						gamelog = gameschedule.gamelogs.new(period: params[:quarter], time: params[:time],
																logentry: "yard pass to", score: "TD", yards: params[:yards],
																player: @athlete.id, assist: player.id)
						gamelog.save!

						if params[:quarter]
							case params[:quarter]
							when "Q1"
								gameschedule.homeq1 = gameschedule.homeq1 + 6
							when "Q2"
								gameschedule.homeq2 = gameschedule.homeq2 + 6
							when "Q3"
								gameschedule.homeq3 = gameschedule.homeq3 + 6
							when "Q4"
								gameschedule.homeq4 = gameschedule.homeq4 + 6
							end
							gameschedule.save!
						end
					end
				end

				if params[:two].to_i > 0
					stats.twopointconv = stats.twopointconv + 1

					if !receiver.nil? and !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
						gamelog = gameschedule.gamelogs.new(period: params[:quarter], time: params[:time],
																					logentry: " yards to", score: "2P", yards: params[:yards], 
																					player: player.id, assist: receiver.id)
						gamelog.save!
						if params[:quarter]
							case params[:quarter]
							when "Q1"
								gameschedule.homeq1 = gameschedule.homeq1 + 2
							when "Q2"
								gameschedule.homeq2 = gameschedule.homeq2 + 2
							when "Q3"
								gameschedule.homeq3 = gameschedule.homeq3 + 2
							when "Q4"
								gameschedule.homeq4 = gameschedule.homeq4 + 2
							end
							gameschedule.save!
						end
					end
				end

				if current_user.score_alert? and params[:td].to_i > 0
					send_alert(@athlete, "Passing score alert for ", stats, gameschedule)
					if !player.nil?
						send_alert(player, "Receiver score alert for ", stats, gameschedule)
					end
				elsif current_user.stat_alert? and params[:two].to_i == 0
					send_alert(@athlete, "Passing stat alert for ", stats, gameschedule)
					if !player.nil?
						send_alert(player, "Receiver stat alert for ", stats, gameschedule)
					end
				end
			end

			stats.save!
		end

		def adjust(stats, athlete, params, gameschedule)
			if params[:comp].to_i > 0
				stats.completions -= 1
				stats.attempts -= 1
			end

			if params[:comp].to_i > 0 and !params[:receiver].nil? and !params[:receiver].blank?
				player = @sport.athletes.find(params[:receiver].to_s)
				receiver = player.football_receivings.find_by(gameschedule_id: gameschedule.id)
				stats.yards -= params[:yards].to_i

				receiver.receptions -= 1
				receiver.yards -= params[:yards].to_i

				if receiver.longest == params[:yards].to_i
					receiver.longest = 0
				end

				if params[:rec_fumble].to_i > 0 and receiver.fumbles > 0
					receiver.fumbles = receiver.fumbles + 1
				end

				if params[:rec_fumble_lost].to_i > 0 and receiver.fumbles_lost > 0
					receiver.fumbles_lost = receiver.fumbles_lost + 1
				end

				receiver.save!		
			else
				raise "yards and receiver must both be filled out to remove a completion"
			end

			if params[:sack].to_i > 0 and stats.sacks > 0
				stats.sacks -= 1
			end

			if params[:int].to_i > 0 and stats.interceptions > 0
				stats.interceptions -= 1
			end

			if params[:yards_lost].to_i > 0 and stats.yards_lost > params[:yards_lost].to_i
				stats.yards_lost -= params[:yards_lost].to_i
			end

			stats.save!
		end

end

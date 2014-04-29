class FootballPassingsController < ApplicationController
	include FootballStatistics

	before_filter	:authenticate_user!
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:update, :destroy]
	before_filter only: [:destroy, :update, :create] do |controller| 
	    controller.SiteOwner?(@athlete.team_id)
	end
#	before_filter do |check|
#		check.packageEnabled?(current_site)
#	end

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
			else
				stats = @athlete.football_passings.new(gameschedule_id: game.id.to_s)
				livestats(stats, @athlete, params, game)				
			end

			respond_to do |format|
		        format.html { redirect_to allfootballgamestats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: game.team_id, 
		        								id: game.id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { passing: stats } }
		    end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football passing stats " + e.message }
		        format.json { render status: 404, json: { error: e.message } }
		     end			
		end
	end

	def show
		if params[:stat_id]
			@fbpassing = FootballPassing.find(params[:stat_id])
		else
			@fbpassing = FootballPassing.new(athlete_id: @athlete.id, gameschedule_id: params[:gameschedule_id])
		end
			@gameschedule = Gameschedule.find(@fbpassing.gameschedule_id)
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
			elsif live == "Adjust"
				adjust(@fbpassing, @athlete_id, params, @gameschedule)
			else
				livestats(@fbpassing, @athlete, params, @gameschedule)
			end

			respond_to do |format|
		        format.html { redirect_to allfootballgamestats_sport_team_gameschedule_path(sport_id: @sport.id, 
		        							team_id: @gameschedule.team_id, id: @gameschedule.id), 
		        							notice: 'Stat updated for ' + @athlete.full_name }

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
		begin
			@fbpassing.destroy
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

	def index
		fbstats = Passingstats.new(@sport, @athlete)
		@stats = fbstats.stats
		@totals = fbstats.passingtotals
	end

	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

		def correct_stat
			@fbpassing = @athlete.football_passings.find(params[:id])
			@gameschedule = Gameschedule.find(@fbpassing.gameschedule_id)
		end

		def livestats(stats, athlete, params, gameschedule)
			receiver = nil
			player = nil

			stats.attempts = stats.attempts + 1
			stats.yards_lost = stats.yards_lost + params[:yards_lost].to_i
			
			if params[:sack].to_i > 0
				stats.sacks = stats.sacks + 1
				gameschedule.lastplay = athlete.logname + " sacked"

				if params[:yards_lost].to_i > 0
					gameschedule.lastplay = gameschedule_.lastplay + " for " + params[:yards_lost].to_s + " loss"
				end
				return
			end

			if params[:int].to_i > 0
				stats.interceptions = stats.interceptions + 1
				gameschedule.lastplay = athlete.logname + " - interception"
				return
			end
						
			if params[:comp].to_i > 0
				stats.completions = stats.completions + 1
				stats.yards = stats.yards + params[:yards].to_i

				if !params[:receiver].nil? and !params[:receiver].blank?
					player = @sport.athletes.find(params[:receiver])

					if player.football_receivings.find_by(gameschedule_id: gameschedule.id).nil?
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

						if !receiver.nil? and !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
							gamelog = gameschedule.gamelogs.new(period: params[:quarter], time: params[:time], score: "TD", yards: params[:yards],
																football_passing_id: stats.id, assist: player.id, logentry: "yard pass to ")
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
							end
						end

						stats.td = stats.td + 1
					elsif params[:two].to_i > 0
						stats.twopointconv = stats.twopointconv + 1

						if !receiver.nil? and !params[:time].nil? and !params[:time].blank? and !params[:quarter].nil? and !params[:quarter].blank?
							gamelog = gameschedule.gamelogs.new(period: params[:quarter], time: params[:time], score: "2P", yards: params[:yards], 
																football_passing_id: stats.id, assist: player.id, logentry: "yard pass to ")
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
							end
						end
					end

					if params[:fd].to_i > 0
						receiver.firstdowns += 1
						stats.firstdowns = stats.firstdowns + 1

						if params[:td].to_i == 0 and params[:two].to_i == 0
							gameschedule.lastplay = athlete.logname + " " +  params[:yards] + " to " + receiver.logname + " - first down"
						end
					else
						gameschedule.lastplay = athlete.logname + " " +  params[:yards] + " to " + receiver.logname
					end

					if params[:rec_fumble].to_i > 0
						receiver.fumbles = receiver.fumbles + 1
					end

					if params[:rec_fumble_lost].to_i > 0
						receiver.fumbles_lost = receiver.fumbles_lost + 1
					end

					receiver.save!		
				end
			else
				gameschedule.lastplay = athlete.logname + "pass incomplete"
			end

			gameschedule.save!
			stats.save!
		end

		def adjust(stats, athlete, params, gameschedule)
			if params[:comp].to_i > 0
				stats.completions -= 1
				stats.attempts -= 1
			end

			if params[:fd].to_i > 0
				stats.firstdowns -= 1
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

				if params[:fd].to_i > 0
					receiver.firstdowns -= 1
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

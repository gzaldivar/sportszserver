class FootballRushingsController < ApplicationController
	include FootballStatistics

	before_filter	:authenticate_user!
  	before_filter 	:get_sport_athlete_stat
  	before_filter	:correct_stat,			only: [:edit, :update, :destroy]
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
	    controller.SiteOwner?(@athlete.team_id)
	end
	before_filter do |check|
		check.packageEnabled?(current_site)
	end

  	def new
		@rushing = FootballRushing.new(gameschedule_id: params[:gameschedule_id])
		@game = @sport.teams.find(@athlete.team_id).gameschedules.find(params[:gameschedule_id])

		if params[:livestats] == "Play by Play"
			@live = "Play by Play"
		elsif params[:livestats] == "Totals"
			@live = "Totals"
		end
	end

	def create
		begin
			if params[:football_rushing].nil?
				game = Gameschedule.find(params[:gameschedule_id].to_s)
				live = params[:livestats].to_s
			else
				game = Gameschedule.find(params[:football_rushing][:gameschedule_id].to_s)
				live = params[:football_rushing][:livestats].to_s
			end

			if live == "Totals"
				stats = @athlete.football_rushings.create!(params[:football_rushing])
			else
				stats = @athlete.football_rushings.new(gameschedule_id: game.id.to_s)
				livestats(stats, @athlete, params, game)				
			end

			respond_to do |format|
		        format.html { redirect_to allfootballgamestats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: game.team_id, 
		        								id: game.id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { rushing: stats } }
		    end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football rushing stats " + e.message }
				format.json { render status: 404, json: { error: e.message } }
		    end
		end
	end

	def show
		if params[:stat_id]
			@rushing = FootballRushing.find(params[:stat_id])
		else
			@rushing = FootballRushing.new(athlete_id: @athlete.id, gameschedule_id: params[:gameschedule_id])
		end
		@gameschedule = Gameschedule.find(@rushing.gameschedule_id)
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
			if params[:football_rushing].nil?
				live = params[:livestats].to_s
			else
				live = params[:football_rushing][:livestats].to_s
			end

			if live == "Totals"
				@rushing.update_attributes!(params[:football_rushing])
			elsif live == "Adjust"
				adjust(@rushing, params)
			else
				livestats(@rushing, @athlete_id, params, @gameschedule)
			end

			respond_to do |format|
		        format.html { redirect_to allfootballgamestats_sport_team_gameschedule_path(sport_id: @sport.id, 
			        							team_id: @gameschedule.team_id, id: @gameschedule.id), 
			        							notice: 'Stat updated for ' + @athlete.full_name }
		        format.json  { render json: { rushing: @rushing } }
		     end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error updating stats for " + @athlete.full_name + " " + e.message }
				format.json { render status: 404, json: { error: e.message } }
		    end
		end 
	end

	def index
		fbstats = Rushingstats.new(@sport, @athlete)
		@stats = fbstats.stats
		@totals = fbstats.rushingtotals
	end

	def destroy
		begin
			@rushing.destroy
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
			@rushing = @athlete.football_rushings.find(params[:id])
			@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(@rushing.gameschedule_id)
		end

		def livestats(stat, athlete, params, game)
			stat.attempts = stat.attempts + 1
			stat.yards = stat.yards + params[:yards].to_i
			stat.fumbles = stat.fumbles + params[:fumble].to_i
			stat.fumbles_lost = stat.fumbles_lost + params[:fumbles_lost].to_i

			if params[:yards].to_i > stat.longest
				stat.longest = params[:yards].to_i
			end

			if params[:fd].to_i > 0
				stat.firstdowns = stat.firstdowns + 1
			end

			if params[:td].to_i > 0
				stat.td = stat.td + params[:td].to_i
			end

			if params[:two].to_i > 0
				stat.twopointconv = stat.twopointconv + params[:two].to_i
			end

			stat.save!

			if params[:td].to_i > 0
				gamelog = game.gamelogs.new(period: params[:quarter], time: params[:time], logentry: "yard run", score: "TD", yards: params[:yards],
																			football_rushing_id: stat.id)
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
			elsif params[:two].to_i > 0
				gamelog = game.gamelogs.new(period: params[:quarter], time: params[:time], logentry: "yard run", score: "TD", yards: params[:yards],
																			football_rushing_id: stat.id)
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

			return stat
		end

		def adjust(stats, params)
			if params[:yards].to_i > 0 and params[:yards].to_i < stats.yards
				stats.yards -= params[:yards].to_i
			end

			if params[:fd].to_i > 0 and stats.firstdowns > 0
				stats.firstdowns -= 1
			end

			if params[:fumble].to_i > 0 and stats.fumbles > 0
				stats.fumbles -= 1
			end

			if params[:fumble_lost].to_i > 0 and stats.fumbles_lost > 0
				stats.fumbles_lost -= 1
			end

			stats.save!
			return stat
		end

end

class SoccersController < ApplicationController
	before_filter	:authenticate_user!, only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport_athlete
  	before_filter	:get_stat, only: [:edit, :update, :destroy, :show]
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
		controller.team_manager?(@athlete, nil)
	end

	def new
		@gameschedule = Gameschedule.find(params[:gameschedule_id].to_s)
		if @gameschedule
			@team = @sport.teams.find(@gameschedule.team_id.to_s)
		end
		@athlete = Athlete.find(params[:athlete_id].to_s)

		if params[:livestats] == "Live"
			@live = "Live"
		elsif params[:livestats] == "Totals"
			@live = "Totals"
		end

		@games = @sport.teams.find(@athlete.team_id.to_s).gameschedules.asc(:starttime)
		@soccers = Soccer.new
	end

	def create
		begin
			if params[:soccer].nil?
				game = Gameschedule.find(params[:gameschedule_id].to_s)
				live = params[:livestats].to_s
			else
				game = Gameschedule.find(params[:soccer][:gameschedule_id].to_s)
				live = params[:soccer][:livestats].to_s
			end

			if live == "Totals"
				stats = @athlete.soccers.create!(params[:soccer])
#				game.homescore = stats.goals
				if !params[:soccer][:goalsagainst].blank? or !params[:soccer][:goalssaved].blank? or
				   !params[:soccer][:shutouts].blank?
				   	@goalie = true
				else
					@goalie = false
				end
			else
				stats = @athlete.soccers.new(gameschedule_id: game.id.to_s)
				@goalie = livestats(stats, @athlete, params)
#				game.homescore += params[:goals].to_i
				
			end

			if params[:goals]
				game.lastplay = @athlete.logname + " Goal Scored"
			end

			game.save!

			respond_to do |format|
				format.html { redirect_to [@sport, @athlete, stats], notice: "Stat created for " + @athlete.logname }
				format.json { render status: 200, json: { soccerstats: stats } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def show
		@gamesplayed = @athlete.soccers.count
		@gameschedule = Gameschedule.find(@stats.gameschedule_id.to_s)
		@team = @sport.teams.find(@gameschedule.team_id)
	end

	def edit
		@gameschedule = Gameschedule.find(@stats.gameschedule_id.to_s)
		@team = @sport.teams.find(@gameschedule.team_id)

		if params[:livestats].nil?
			@live = nil
		elsif params[:livestats] == "Live"
			@live = "Live"
		else
			@live = "Totals"
		end
	end

	def update
		begin
			if params[:soccer].nil?
				game = Gameschedule.find(params[:gameschedule_id].to_s)
				live = params[:livestats].to_s
			else
				game = Gameschedule.find(params[:soccer][:gameschedule_id].to_s)
				live = params[:soccer][:livestats].to_s
			end

			if live == "Totals"
				@stats.update_attributes!(params[:soccer])
#				game.homescore = @stats.goals
			else
				livestats(@stats, @athlete, params)
#				game.homescore += params[:goals].to_i				
			end

			if params[:goals]
				game.lastplay = @athlete.logname + " Goal Scored"
			end

			game.save!

			respond_to do |format|
				format.html { redirect_to [@sport, @athlete, @stats], notice: "Stat created for " + @athlete.logname }
				format.json { render status: 200, json: { soccerstats: @stats } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def index
		if params[:athlete_id]
			@athlete = @sport.athletes.find(params[:athlete_id].to_s)
		end

		if params[:gameschedule_id]
			@gameschedule = @sport.gameschedules.find(params[:gameschedule_id].to_s).asc(:starttime)
			@team = @sport.teams.find(@gameschedule.team_id)
		end

		if !@athlete.nil? and !@gameschedules.nil?
			@stats = []
			@stats[0] = @athlete.soccers.where(gameschedule_id: @gameschedule.id.to_s)
		elsif !@athlete.nil?
			@stats = @athlete.soccers
			@gameschedules = Gameschedule.where(team_id: @athlete.team_id).asc(:starttime)
		elsif !gameschedule.nil?
			@stats = @gameschedule.soccers
			@athletes = Athlete.where(team_id: @gameschedule.team_id).asc(:number)
		end
			
		respond_to do |format|
			format.html
			format.json {
				astats = @stats
				@stats = []
				@gameschedules.each_with_index do |g, cnt|
					thestat = nil
					astats.each do |b|
						if g.id == b.gameschedule_id
							thestat = b
							break
						end
					end
					if thestat.nil?
						thestat = Soccer.new(gameschedule: g.id, athlete: @athlete.id)
					end
					@stats[cnt] = thestat
				end
			}
		end
	end

	def destroy
		
	end

	private

		def get_sport_athlete
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

		def get_stat
			@stats = @athlete.soccers.find(params[:id])
		end

		def livestats(stats, athlete, params)
			begin
				goalie = false

				if params[:goals].to_i == 1
					stats.goals += 1
					if params[:shottaken].to_i == 0
						stats.shotstaken += 1
					end
				end

				if params[:shottaken].to_i == 1
					stats.shotstaken += 1
				end

				if params[:assists].to_i == 1
					stats.assists += 1
				end

				if params[:steals].to_i == 1
					stats.steals += 1
				end

				if params[:cornerkick].to_i == 1
					stats.cornerkick += 1
				end

				if params[:goalsagainst].to_i == 1
					stats.goalsagainst += 1
					goalie = true
				end

				if params[:goalssaved].to_i == 1
					stats.goalssaved += 1
					goalie = true
				end

				if params[:shutouts].to_i == 1
					stats.shutouts += 1
					goalie = true
				end

				if params[:minutesplayed].to_i > 0
					stats.minutesplayed = params[:minutesplayed].to_i
				end

				stats.save!
				return goalie
			rescue Exception => e
				throw "Error updating live stats!"
			end
		end

end

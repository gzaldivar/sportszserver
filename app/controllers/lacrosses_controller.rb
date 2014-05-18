class LacrossesController < ApplicationController

	include LacrosseStatistics

	before_filter	:authenticate_user!, only: [:destroy, :update, :create, :edit, :new]
  	before_filter 	:get_sport_athlete
  	before_filter	:get_lacrossestats, only: [:edit, :update, :destroy, :show]
	before_filter 	only: [:destroy, :update, :create, :edit, :new] do |controller| 
		controller.SiteOwner?(@athlete.team_id)
	end

	def new
		@gameschedule = Gameschedule.find(params[:gameschedule_id].to_s)

		if @gameschedule
			@team = @sport.teams.find(@gameschedule.team_id.to_s)
		end

		@athlete = Athlete.find(params[:athlete_id].to_s)
		@lacrossestats = @athlete.lacrosses.new(gameschedule_id: @gameschedule.id)
	end

	def create
		begin
			game = Gameschedule.find(params[:lacrosse][:gameschedule_id].to_s)

			lacrossestats = @athlete.lacrosses.create!(params[:lacrosse])

			if params[:goal].to_i > 0
				game.lastplay = @athlete.logname + " Goal Scored"
				game.save!
				createGamelog(lacrossestats, game)
			end

			respond_to do |format|
				format.html { redirect_to [@sport, @athlete, lacrossestats], notice: "Stat created for " + @athlete.logname }
				format.json { render status: 200, json: { lacrosselacrossestats: lacrossestats } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def show
		@gamesplayed = @athlete.lacrosses.count
		@gameschedule = Gameschedule.find(@lacrossestats.gameschedule_id)
		@team = @sport.teams.find(@gameschedule.team_id)
	end

	def edit
		@gameschedule = Gameschedule.find(@lacrossestats.gameschedule_id.to_s)
		@team = @sport.teams.find(@gameschedule.team_id)
	end

	def update
		begin
			game = Gameschedule.find(params[:lacrosse][:gameschedule_id].to_s)
			goals = @lacrossestats.goals
			@lacrossestats.update_attributes!(params[:lacrosse])

			if goals < @lacrossestats.goals
				game.lastplay = @athlete.logname + " Goal Scored"
				game.save!
				createGamelog(@lacrossestats, game)
			end

			respond_to do |format|
				format.html { redirect_to [@sport, @athlete, @lacrossestats], notice: "Stat created for " + @athlete.logname }
				format.json { render status: 200, json: { lacrosselacrossestats: @lacrossestats } }
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

		if !@athlete.nil?
			thestats = LacrosseStatistics.new(@sport, @athlete)
			@lacrossestats = thestats.stats
			@gameschedules = Gameschedule.where(team_id: @athlete.team_id).asc(:starttime)
		elsif !gameschedule.nil?
			thestats = LacrosseStatistics.new(@sport, @gameschedule)
			@lacrossestats = thestats.stats
			@athletes = Athlete.where(team_id: @gameschedule.team_id).asc(:number)
		end
	end

	def destroy
		
	end

	private

		def createGamelog(lacrosse, game, time)
			game.gamelogs.create!(period: game.currentperiod.to_s, time: time, logentry: "Goal Scored", score: "Goal", lacrosse_id: lacrosse.id)
		end

		def get_sport_athlete
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

		def get_lacrossestats
			@lacrossestats = @athlete.lacrosses.find(params[:id])
		end

		def livelacrossestats(lacrossestats, athlete, params)
			begin
			rescue Exception => e
				throw "Error updating live lacrossestats!"
			end
		end

		def updateLacrossStats(stats)
		end

end

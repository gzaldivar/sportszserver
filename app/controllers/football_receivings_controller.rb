class FootballReceivingsController < ApplicationController
	include FootballStatistics

	before_filter	[:authenticate_user!, :site_owner?]
  	before_filter 	:get_sport_athlete_stat, only: [:new, :playbyplay, :create, :show, :edit, :update, :destroy, :index]
  	before_filter	:correct_stat,			only: [:edit, :update, :destroy]

  	def new
		@receiving = FootballReceiving.new
		@game = @sport.teams.find(@athlete.team_id).gameschedules.find(params[:gameschedule_id])

		if params[:livestats] == "Play by Play"
			@live = "Play by Play"
		elsif params[:livestats] == "Totals"
			@live = "Totals"
		end
	end

	def create
		begin
			@receiving = @athlete.football_receivings.create!(params[:football_receiving])

			respond_to do |format|
		        format.html { redirect_to allfootballgamestats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: @athlete.team_id, 
		        								id: @receiving.gameschedule_id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { receiving: @receiving } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error creating football receiving stats" }	
		        format.json { render json: { error: e.message } }
		     end			
		end
	end

	def show
		if params[:stat_id]
			@receiving = FootballReceiving.find(params[:stat_id])
		else
			@receiving = FootballReceiving.new(athlete_id: @athlete.id, gameschedule_id: params[:gameschedule_id])
		end
		@gameschedule = Gameschedule.find(@receiving.gameschedule_id)
	end

	def edit		
	end

	def update
		begin
			@receiving.update_attributes!(params[:football_receiving])

			respond_to do |format|
		        format.html { redirect_to allfootballgamestats_sport_team_gameschedule_path(sport_id: @sport.id, team_id: @athlete.team_id, 
		        								id: @receiving.gameschedule_id), notice: 'Stat created for ' + @athlete.full_name }
		        format.json { render json: { receiving: @receiving } }
		     end			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error updating stats for " + @athlete.full_name }		
		        format.json { render json: { receiving: @receiving } }
		     end			
		end
	end

	def index
		fbstats = Receivingstats.new(@sport, @athlete)
		@stats = fbstats.stats
		@totals = fbstats.receivingtotals
	end

	def destroy
		@receiving.destroy
		redirect_to sport_athlete_path(@sport, @athlete)
	end

	private

		def get_sport_athlete_stat
			@sport = Sport.find(params[:sport_id])
			@athlete = Athlete.find(params[:athlete_id])
		end

		def correct_stat
			@receiving = @athlete.football_receivings.find(params[:id])
			@gameschedule = @sport.teams.find(@athlete.team_id).gameschedules.find(@receiving.gameschedule_id)
		end
		
		def send_alert(athlete, message)	
	        athlete.fans.each do |user|
	            alert = athlete.alerts.create!(sport: @sport, user: user, athlete: athlete, message: message + @stat.gameschedule.game_name, 
	                								 football_stat: @stat.id, stat_football: "Receiving")
	        end
		end

end

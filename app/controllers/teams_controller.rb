class TeamsController < ApplicationController
  before_filter :authenticate_user! #,   only: [:new, :create, :edit, :update, :destroy, :index, :show, :getplayers, :addplayers]
  before_filter :site_owner?,           only: [:new, :create, :edit, :update, :destroy, :addplayers]
  before_filter :get_sport
  before_filter :get_team,	only: [:edit, :update, :show, :destroy, :getplayers, :addplayers, :createteamlogo, :teamlogo]

	def new
		@team = Team.new
	end

	def create
		begin
			@team = @sport.teams.create!(params[:team])
			respond_to do |format|
				format.html { redirect_to @sport, notice: "Added #{@team.title} #{@team.mascot}!" }
				format.json { render json: { team: @team, request: sport_team_url(@sport, @team) } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to @sport, alert: "Error adding team" }
				format.json { render json: { error: e.message, request: sport_team_url(@sport, @team) } }
			end
		end
	end

	def edit
	end

	def update
		begin
			@team.update_attributes!(params[:team])
			respond_to do |format|
				format.html { redirect_to @sport, notice: "Team updated" }
				format.json { render json: { team: @team, request: sport_team_url(@sport, @team) } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to @sport, alert: "Error updating team" }
				format.json  { render json: { error: e.message, request: sport_team_url(@sport, @team) } }
			end
		end
	end

	def index
		@teams = @sport.teams.all.entries
	end

	def show
		respond_to do |format|
			format.html
			format.json
		end
	end

	def destroy
		begin
			destroy_team(@team.id.to_s)
			@team.destroy
			respond_to do |format|
				format.html { redirect_to @sport, notice: "Team delete sucessful!" }
				format.json { render json: { success: "success", request: @sport } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to @sport, alert: "Error deleting team " + e.message }
				format.json { render status: 404, json: { error: e.message, request: [@sport, @team] } }
			end
		end
	end

	def addplayers
		begin
		    if params[:pass_players]
		     	 params[:pass_players].each do |key,value|
		        	if player = Athlete.find(value.to_s)
		            	@team.fb_pass_players = Array.new
		          		@team.fb_pass_players.push(value)
		        	else
		          		throw "Athlete does not exist"
		        	end
		      	end
		    end
		    if params[:rush_players]	      		
		     	 params[:rush_players].each do |key,value|
		        	if player = Athlete.find(value.to_s)
		            	@team.fb_rush_players = Array.new
		          		@team.fb_rush_players.push(value)
		        	else
		          		throw "Athlete does not exist"
		        	end
		      	end
		    end
		    if params[:rec_players]	      		
		     	 params[:rec_players].each do |key,value|
		        	if player = Athlete.find(value.to_s)
		            	@team.fb_rec_players = Array.new
		          		@team.fb_rec_players.push(value)
		        	else
		          		throw "Athlete does not exist"
		        	end
		      	end
		    end
		    if params[:def_players]	      		
		     	 params[:def_players].each do |key,value|
		        	if player = Athlete.find(value.to_s)
		            	@team.fb_def_players = Array.new
		          		@team.fb_def_players.push(value)
		        	else
		          		throw "Athlete does not exist"
		        	end
		      	end
		    end
		    if params[:spec_players]	      		
		     	 params[:spec_players].each do |key,value|
		        	if player = Athlete.find(value.to_s)
		            	@team.fb_spec_players = Array.new
		          		@team.fb_spec_players.push(value)
		        	else
		          		throw "Athlete does not exist"
		        	end
		      	end
			end
			if params[:placekicker]
				if player = Athlete.find(params[:placekicker].to_s)
					@team.placekicker = params[:placekicker].to_s
				end
			end
			if params[:punter]
				if player = Athlete.find(params[:punter].to_s)
					@team.punter = params[:punter].to_s
				end
			end
			if params[:kicker]
				if player = Athlete.find(params[:kicker].to_s)
					@team.kicker = params[:kicker].to_s
				end
			end
		    @team.save!
		    respond_to do |format|
		      format.json { render json: { team: @team, request: sport_team_url(@sport, @team) } }
		    end
		rescue Exception => e
		  render status: 404, json: { error: e.message }
		end
	end

	def getplayers
	end

	def createteamlogo
	    begin    
	      path = params[:filepath].split('/')
	      imagepath = CGI.unescape(path[2])
	      @team.logoprocessing = true

	      @team.save!

	      queue = @sport.photo_queues.new(modelid: @team.id, modelname: "teamlogo", filename: params[:filename], filetype: params[:filetype], 
	                                      filepath: imagepath)
	      if queue.save!
	        Resque.enqueue(PhotoProcessor, queue.id)
	      end
	    rescue Exception => e
	    	puts e.message
	    end
	end

	def updatelogo
		begin
		    @team.logoprocessing = true

		    @team.save!

		    queue = @sport.photo_queues.new(modelid: @team.id, modelname: "teamlogo", filename: params[:filename], filetype: params[:filetype], 
		                                      filepath: params[:filepath])
		    if queue.save!
		        Resque.enqueue(PhotoProcessor, queue.id)
		    end

		    respond_to do |format|
		        format.json { render json: { success: "success", team: @team } }
		    end
	    rescue Exception => e
		    respond_to do |format|
		        format.json { render status: 404, json: { error: e.message, team: @team } }
		    end
	    end
	end

	def teamlogo
	end

	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
		end

		def get_team
			@team = @sport.teams.find(params[:id])
		end

		def destroy_team(team)
			@sport.photos.where(teamid: team).each do |p|
				p.teamid = nil
				p.save
			end
			@sport.videoclips.where(teamid: team).each do |v|
				v.teamid = nil
				v.save
			end
		end
end

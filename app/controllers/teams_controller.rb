class TeamsController < ApplicationController
  before_filter :authenticate_user!,   only: [:new, :create, :edit, :update, :destroy]
  before_filter :get_sport
  before_filter :get_team,	only: [:edit, :update, :show, :destroy, :getplayers, :addplayers, :createteamlogo, :teamlogo, :updatelogo]
  before_filter only: [:edit, :update, :destroy, :addplayers] do |controller|
  	SiteOwner?(@team.id)
  end

	def new
		@team = Team.new
	end

	def create
		begin
			@team = @sport.teams.create!(params[:team])
			respond_to do |format|
				format.html { redirect_to @sport, notice: "Added #{@team.title} #{@team.mascot}!" }
				format.json { render json: { team: @team } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to @sport, alert: "Error adding team" }
				format.json { render json: { error: e.message } }
			end
		end
	end

	def edit
	end

	def update
		begin
			@team.update_attributes!(params[:team])

			if params[:followteam] and user_signed_in?
				if @team.fans.nil?
					@team.fans = Array.new
				end
				if params[:followteam].to_i == 1 and !@team.fans.include?(current_user.id.to_s)
					@team.fans << current_user.id.to_s
				elsif params[:followteam].to_i == 0
					@team.fans.delete(current_user.id.to_s)
				end
				@team.save!
			end

			respond_to do |format|
				format.html { redirect_to @sport, notice: "Team updated succesful" }
				format.json { render json: { team: @team } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to @sport, alert: "Error updating team" }
				format.json  { render json: { error: e.message } }
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
			@team.athletes = nil
			@team.coaches = nil
			@team.photos = nil
			@team.destroy
			respond_to do |format|
				format.html { redirect_to @sport, notice: "Team delete sucessful!" }
				format.json { render json: { success: "success", request: @sport } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to @sport, alert: "Error deleting team " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
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

		def addplayers
			begin
			    if params[:pass_players]
	            	@team.fb_pass_players = Array.new
			     	 params[:pass_players].each do |key,value|
			        	if player = Athlete.find(value.to_s)
			          		@team.fb_pass_players.push(value)
			        	else
			          		raise "Athlete does not exist"
			        	end
			      	end
			    end
			    if params[:rush_players]	      		
			     	 params[:rush_players].each do |key,value|
			        	if player = Athlete.find(value.to_s)
			            	@team.fb_rush_players = Array.new
			          		@team.fb_rush_players.push(value)
			        	else
			          		raise "Athlete does not exist"
			        	end
			      	end
			    end
			    if params[:rec_players]	      		
			     	 params[:rec_players].each do |key,value|
			        	if player = Athlete.find(value.to_s)
			            	@team.fb_rec_players = Array.new
			          		@team.fb_rec_players.push(value)
			        	else
			          		raise "Athlete does not exist"
			        	end
			      	end
			    end
			    if params[:def_players]	      		
			     	 params[:def_players].each do |key,value|
			        	if player = Athlete.find(value.to_s)
			            	@team.fb_def_players = Array.new
			          		@team.fb_def_players.push(value)
			        	else
			          		raise "Athlete does not exist"
			        	end
			      	end
			    end
			    if params[:fb_placekickers]	      		
			     	 params[:fb_placekickers].each do |key,value|
			        	if player = Athlete.find(value.to_s)
			            	@team.fb_placekickers = Array.new
			          		@team.fb_placekickers << value
			        	else
			          		raise "Athlete does not exist"
			        	end
			      	end
				end
				if params[:fb_kickers]
					params[:fb_kickers].each do |key, value|
						@team.fb_kickers = Array.new
						@team.fb_kickers << params[:fb_kickers].to_s
					end
				end
				if params[:fb_punters]
					params[:fb_punters].each do |key, value|
						@team.fb_punters = Array.new(10) { iii }
						@team.fb_punters << params[:fb_punters].to_s
					end
				end
				if params[:kicker]
					if player = Athlete.find(params[:kicker].to_s)
						@team.kicker = params[:kicker].to_s
					end
				end
			    @team.save!
			    respond_to do |format|
			      format.json { render json: { team: sport_team_url(@sport, @team) } }
			    end
			rescue Exception => e
			  render status: 404, json: { error: e.message }
			end
		end

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

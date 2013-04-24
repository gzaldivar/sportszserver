class EventsController < ApplicationController
	before_filter :authenticate_user!,  only: [:new, :create, :edit, :update, :destroy]
  	before_filter :get_sport
  	before_filter :get_event,			only: [:edit, :update, :show, :destroy]
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
	    controller.team_manager?(@event, nil)
	end

	def new
		@event = Event.new
	end

	def newteam
		@event = Event.new
		@team = @sport.teams.find(params[:team_id])
		@event.team_id = @team.id
		render 'new'
	end

	def create
		begin 
			@event = @sport.events.create!(params[:event])
			redirect_to [@sport, @event], notice: "Added #{@event.name}!"
		rescue Exception => e
			redirect_to :back, alert: "Error adding event " + e.message
		end
	end

	def edit
	end

	def update
		begin
			event = @sport.events.find(params[:id])
			event.update_attributes!(params[:event])
			redirect_to [@sport, event], notice: "event updated"
		rescue Exception => e
			redirect_to [@sport, event], alert: "Error updating event" + e.message
		end
	end

	def index
	    if  !params[:team_id].nil?
	    	@team = @sport.teams.find(params[:team_id])
			@events = @sport.events.where(team: params[:team_id].to_s)
#			schedules = @team.gameschedules
#			@events = @events + schedules
		else
			@events = @sport.events.all.entries
	  	end

	  	respond_to do |format|
	  		format.html
	  		format.json
	  	end
	end

	def show
	  	respond_to do |format|
	  		format.html
	  		format.json
	  	end
	end

	def destroy
		if @event.team_id.nil?
			@event.destroy
			redirect_to sport_events_path(@sport), notice: "event delete sucessful!"
		else
			@team = @sport.teams.find(@event.team_id)
			@event.destroy
			redirect_to sport_events_path(@sport, @team), notice: "Event deleted for " + @team.team_name
		end
	end

	private

		def get_sport
			@sport = Sport.find(params[:sport_id])
		end

		def get_event
			@event = @sport.events.find(params[:id])
		end
end

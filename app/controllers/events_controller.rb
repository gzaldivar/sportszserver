class EventsController < ApplicationController
	before_filter :authenticate_user!,  only: [:new, :create, :edit, :update, :destroy]
  	before_filter :get_sport
  	before_filter :get_event,			only: [:edit, :update, :show, :destroy]
	before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
		if @event
	    	controller.SiteOwner?(@event.team_id.nil? ? nil : @event.team_id)
	    elsif params[:team_id]
	    	controller.SiteOwner?(params[:team_id])
	    end
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
			event = @sport.events.build(params[:event])
			startdate = DateTime.iso8601(params[:event][:start_time])
			enddate = DateTime.iso8601(params[:event][:end_time])

			if params[:starthour]
				if params[:ampm] == "PM" and params[:starthour].to_i != 12
					params[:starthour] = (params[:starthour].to_i + 12).to_s
				end
				event.start_time = startdate.change({:hour => params[:starthour].to_i , :min => params[:startminutes].to_i , :sec => 0 })
			else
				event.start_time = startdate
			end

			if params[:endhour]
				if params[:endampm] == "PM" and params[:endhour].to_i != 12
					params[:endhour] = (params[:endhour].to_i + 12).to_s
				end
				event.end_time = enddate.change({:hour => params[:endhour].to_i , :min => params[:endminutes].to_i , :sec => 0 })
			else
				event.end_time = enddate
			end

			event.save!

			respond_to do |format|
				format.html { redirect_to [@sport, event], notice: "Added Event" }
				format.json { render status: 200, json: { event: event } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error adding event " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def edit
	end

	def update
		begin
			@event.update_attributes!(params[:event])

			startdate = Time.iso8601(params[:event][:start_time])
			enddate = Time.iso8601(params[:event][:end_time])

			if params[:starthour]
				if params[:ampm] == "PM" and params[:starthour].to_i != 12
				  hour = (params[:starthour].to_i + 12)
				else
				  hour = params[:starthour].to_i
				end
				@event.start_time = startdate.change({:hour => hour , :min => params[:startminutes].to_i , :sec => 0 })
			elsif params[:event][:"start_time(4i)"] and params[:event][:"start_time(5i)"]
				@event.start_time = startdate
			end

			if params[:endhour]
				if params[:endampm] == "PM" and params[:endhour].to_i != 12
				  hour = (params[:endhour].to_i + 12)
				else
				  hour = params[:endhour].to_i
				end
				@event.end_time = enddate.change({:hour => hour , :min => params[:endminutes].to_i , :sec => 0 })
			elsif params[:event][:"end_time(4i)"] and params[:event][:"end_time(5i)"]
				@event.end_time = enddate
			end

			@event.save!

			respond_to do |format|
				format.html { redirect_to [@sport, @event], notice: "Added #{@event.name}!" }
				format.json { render status: 200, json: { event: @event } }
			end
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to :back, alert: "Error updating event " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end
		end
	end

	def index
		if params[:gameschedule_id]
			@team = @sport.teams.find(params[:team_id])
			@gameschedule = @team.gameschedules.find(params[:gameschedule_id])

	    	if params[:startdate]
	   			@events = @sport.events.where(gameschedule_id: @gameschedule.id.to_s, :start_time.gte =>  params[:startdate], 
	   															:end_time.lte => params[:enddate])
	    	else
	   			@events = @sport.events.where(gameschedule_id: @gameschedule.id.to_s)
			end
			
		elsif !params[:name].nil?
			@team = @sport.teams.find(params[:team_id])

			@events = @sport.events.where(team_id: @team.id).full_text_search(params[:name].to_s)
	    elsif !params[:team_id].nil?
	    	@team = @sport.teams.find(params[:team_id])

	    	if params[:startdate]
				@events = @sport.events.where(team_id: params[:team_id].to_s, :start_time.gte =>  params[:startdate], 
	   															:end_time.lte => params[:enddate])
	    	else
				@events = @sport.events.where(team_id: params[:team_id].to_s)
			end

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
		begin
			if @event.team_id.nil?
				@event.destroy

				respond_to do |format|
					format.html { redirect_to sport_events_path(@sport), notice: "Event delete sucessful!" }
					format.json { render status: 200, json: { success: "success" } }
				end
			else
				@team = @sport.teams.find(@event.team_id)
				@event.destroy

				respond_to do |format|
					format.html { redirect_to sport_events_path(@sport, team_id: @team.id), notice: "Event deleted for " + @team.team_name }
					format.json { render status: 200, json: { success: "success" } }
				end
			end
			
		rescue Exception => e
			respond_to do |format|
				format.html { redirect_to sport_events_path(@sport), alert: "Error deleting event " + e.message }
				format.json { render status: 404, json: { error: e.message } }
			end			
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

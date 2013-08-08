class CoachesController < ApplicationController
	before_filter	:authenticate_user! #,	only: [:destroy, :update, :create, :edit, :new]
  before_filter :get_sport
	before_filter	:correct_coach,	      only:	[:show, :edit, :update, :destroy, :updatephoto]
  before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
    controller.team_manager?(@coach, nil)
  end
	
  def new
    @coach = Coach.new
  end
	
	def create
    begin
      coach = @sport.coaches.create!(params[:coach])                 
      respond_to do |format|
        format.html { redirect_to [@sport, coach], notice: 'Coach created!' }
        format.json { render json: { coach: coach, request: [@sport, @coach] } }
      end
    rescue Exception => e
      respond_to do |format|    
        format.html { redirect_to :back, alert: "Error saving coach. " + e.message }
        format.json { render status: 401, json: { error: e.message, request: @sport } }
      end
    end
	end
	
	def show
    if !@coach.nil? and !@coach.team_id.nil?
      @team = @sport.teams.find(@coach.team_id)
    end
    respond_to do |format|
      format.html 
      format.json 
    end
	end
  
  def index
    @coaches = []
    if params[:team_id]
      coach = @sport.coaches.where(team_id: params[:team_id].to_s)
      @team = @sport.teams.find(params[:team_id])
    else
      coach = @sport.coaches.all
    end

    coach.each_with_index do |c, cnt|
        @coaches[cnt] = c
    end

    respond_to do |format|
      format.html 
      format.json 
    end
  end
	
	def edit
    respond_to do |format|
      format.html
      format.xml
      format.json 
      format.js
    end
	end
	
	def update
    begin
      @coach.update_attributes!(params[:coach])
      respond_to do |format|   
        format.html { redirect_to [@sport, @coach], notice: 'Update successful!' }
        format.json { render json: { coach: @coach, request: [@sport, @coach] } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: 'Error updating coach information ' + e.message }
        format.json { render status: 401, json: { error: e.message, request: [@sport, @coach] } }
      end
    end        
	end
	
	def destroy
    begin
      @coach.delete
      respond_to do |format|    
        format.html { redirect_to sport_coaches_path(@sport) }
        format.json { render json: { message: "success", request: sport_coaches_path(@sport) } }
      end
      puts 'rendered result'
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to @sport, alert: "Error deleting coach " + e.message }
        format.json { render status: 401, json: { error: e.message, request: @sport } }
      end
    end
	end
	
	def copy
	end

  def createcoachphoto
    begin
      path = CGI.unescape(params[:filepath]).split('/')
      @coach = @sport.coaches.find(path[4])    
      path = params[:filepath].split('/')
      imagepath = CGI.unescape(path[2])
      @coach.processing = true

      @coach.save!

      queue = @sport.photo_queues.new(modelid: @coach.id, modelname: "coaches", filename: params[:filename], filetype: params[:filetype], filepath: imagepath)
      if queue.save!
        Resque.enqueue(PhotoProcessor, queue.id)
      end
    rescue Exception => e
      puts e.message
    end
  end

  def updatephoto
    begin    
      @coach.processing = true

      @coach.save!

      queue = @sport.photo_queues.new(modelid: @coach.id, modelname: "coaches", filename: params[:filename], filetype: params[:filetype], 
                                      filepath: params[:filepath])
      if queue.save!
        Resque.enqueue(PhotoProcessor, queue.id)
      end

      respond_to do |format|
        format.json { render json: { success: "success", coach: @coach } }
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render status: 404, json: { error: e.message, coach: @coach } }
      end
    end
  end

	private
	
    def correct_coach
    	@coach = @sport.coaches.find(params[:id])
    end

    def get_sport
      @sport = Sport.find(params[:sport_id])
    end

end

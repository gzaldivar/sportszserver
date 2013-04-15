class CoachesController < ApplicationController
	before_filter	:authenticate_user!,	only: [:destroy, :update, :create, :edit, :new]
  before_filter :get_sport
	before_filter	:correct_coach,	      only:	[:show, :edit, :update, :destroy]
  before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
    controller.team_manager?(@coach, nil)
  end
	
  def new
    @coach = Coach.new
  end
	
	def create
    if coach = @sport.coaches.create(params[:coach])                 
      respond_to do |format|
        format.html { redirect_to [@sport, coach], notice: 'Coach created!' }
        format.json 
      end
    else      
      redirect_to :back, alert: "Error saving coach."
    end
	end
	
	def show
    if !@coach.team_id.nil?
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
    if @coach.update_attributes(params[:coach])      
      redirect_to [@sport, @coach], notice: 'Update successful!'
    else
      redirect_to :back, alert: 'Error updating coach information for ' + @sport.name
    end        
	end
	
	def destroy
    @coach.delete    
    redirect_to sport_coaches_path(@sport)
	end
	
	def copy
	end

	private
	
    def correct_coach
    	@coach = @sport.coaches.find(params[:id])
    end

    def get_sport
      @sport = Sport.find(params[:sport_id])
    end

end

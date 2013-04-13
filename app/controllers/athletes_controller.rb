class AthletesController < ApplicationController  
	before_filter	[:authenticate_user!, :site_owner?],	only: [:destroy, :update, :create, :edit, :new]
  before_filter :get_sport
  before_filter :correct_athlete,     only: [:show, :edit, :update, :destroy, :follow, :unfollow]
  
  def new    
    @athlete = Athlete.new
  end
  
  def create
    athlete = @sport.athletes.build(params[:athlete]) 
    update_team(athlete)
    if @sport.name == "Football"
      update_postions(athlete)
    end
    update_height(athlete)
    if athlete.save
      respond_to do |format|
        format.html { redirect_to [@sport, athlete], notice: 'Athlete created!'}
        format.xml
        format.json 
        format.js
      end
    else     
      redirect_to :back, alert: "Error creating athlete"
    end
  end
  
  def show
    if @athlete.team == "Unassigned"
      @team = nil
    else 
      @team = @sport.teams.find(@athlete.team)
    end 

    @photos = Photo.where(athletes: @athlete.id)
  end
  
  def edit
    @sport = Sport.find(@athlete.sport)
  end
  
  def update
    update_team(@athlete)
    if @sport.name == "Football"
      update_postions(@athlete)
    end
    update_height(@athlete)
    if @athlete.update_attributes(params[:athlete])
      respond_to do |format|
        format.html { redirect_to [@sport, @athlete], notice: "Update successful" }
        format.xml
        format.json 
        format.js
      end
    else
      redirect_to :back, alert: "Update fialed!"
    end        
  end
  
  def destroy
#    delete_athlete_photo(@athlete.id)
#    @athlete.deletephoto
    @athlete.destroy    
          
    respond_to do |format|
      format.html { redirect_to sport_athletes_path(@sport) }
      format.xml
      format.json 
      format.js
    end
  end
  
  def index
    @athletes = []
    
    if !params[:lastname].blank? && !params[:number].blank?
      players = Athlete.where(sport_id: params[:sport_id]).full_text_search(params[:lastname].to_s + " " + params[:number].to_s, match: :all)
    elsif !params[:lastname].blank?
      players = Athlete.where(sport_id: params[:sport_id]).full_text_search(params[:lastname].to_s).asc(:number)
    elsif !params[:number].blank?
      players = Athlete.where(sport_id: params[:sport_id]).full_text_search(params[:number].to_s)
    elsif params[:team_id]
      players = Athlete.where(sport_id: params[:sport_id]).full_text_search(params[:team_id].to_s).asc(:number)
      @team = @sport.teams.find(params[:team_id])
    else
      players = Athlete.where(sport_id: params[:sport_id]).asc(:number)
    end
    
    players.each_with_index do |p, cnt|
      @athletes[cnt] = p
    end

    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def follow
    if user_signed_in? 
      @athlete.followers[current_user.id] = current_user.name
    end
    @athlete.save
    redirect_to [@sport, @athlete], notice: "Now following athlete " + @athlete.full_name
  end
  
  def unfollow
    if user_signed_in?
      @athlete.followers.delete(current_user.id.to_s)
      @athlete.save
    end
    redirect_to :back, notice: "No longer following " + @athlete.full_name
  end
  
  private
    
    def correct_athlete
      @athlete = @sport.athletes.find(params[:id])
    end

		def get_sport
			@sport = Sport.find(params[:sport_id])
		end
		
		def update_team(athlete)
      if !params[:athteam][:team].blank?
        team = @sport.teams.find(params[:athteam][:team].to_s)
        if params[:unassign]
          athlete.team = "Unassigned"
        else 
          athlete.team = team.id
        end
      end
	  end

    def update_postions(athlete)
      if !params[:offpos].nil? and !params[:offpos].blank?
        athlete.position = params[:offpos]
      end
      if !params[:defpos].nil? and !params[:defpos].blank?
        athlete.position = athlete.position + "/" + params[:defpos]
      end
      if !params[:special_teamspos].nil? and !params[:special_teamspos].blank?
        athlete.position = athlete.position + "/" + params[:special_teamspos]
      end
    end

    def update_height(athlete)
      if !params[:feet].nil?
        athlete.height = params[:feet]
      end
      if !params[:inches].nil?
        athlete.height = athlete.height + "-" + params[:inches]
      end
    end
    
end

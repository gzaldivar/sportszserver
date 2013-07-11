class AthletesController < ApplicationController  
	before_filter	:authenticate_user!,	only: [:destroy, :update, :create, :edit, :new, :follow, :unfollow]
 #  before_filter :site_owner?,         only: [:destroy, :update, :create, :edit, :new]
  before_filter :get_sport
  before_filter :correct_athlete,     only: [:show, :edit, :update, :destroy, :follow, :unfollow, :stats]
  before_filter only: [:destroy, :update, :create, :edit, :new] do |controller| 
    controller.team_manager?(@athlete, nil)
  end
  
  def new    
    @athlete = Athlete.new
    @height = []
    if @sport.sportname == "Football"
      @position = []
    end
  end
  
  def create
    begin
      athlete = @sport.athletes.build(params[:athlete]) 
      if @sport.name == "Football"
        update_postions(athlete)
      end
      update_height(athlete)
      athlete.fans = Array.new
      athlete.save!
      respond_to do |format|
        format.html { redirect_to [@sport, athlete], notice: 'Athlete created!'}
        format.json { render json: { athleteid: athlete.id.to_s, request: [@sport, athlete] } }
      end
    rescue Exception => e
      respond_to do |format|   
        format.html { redirect_to :back, alert: "Error creating athlete" }
        format.json { render status: 404, json: { error: e.message, request: [@sport, @athlete] } }
      end
    end
  end
  
  def show
    if !@athlete.team_id.nil?
      @team = @sport.teams.find(@athlete.team_id)
    end
    @photos = @sport.photos.where(players: @athlete.id.to_s)

    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def edit
    @sport = Sport.find(@athlete.sport)
    if @athlete.height != '-'
      @height = @athlete.height.split('-')
    else
      @height = []
    end
    if @sport.name == "Football"
      if @athlete.position.nil?
        @position = []
      else
        @position = @athlete.position.split('/')
      end
    end
  end
  
  def update
    begin
      if @sport.name == "Football"
        update_postions(@athlete)
      end
      update_height(@athlete)
      @athlete.update_attributes!(params[:athlete])
      respond_to do |format|
          format.html { redirect_to [@sport, @athlete], notice: "Update successful" }
          format.json { render json: { athleteid: @athlete.id.to_s, request: [@sport, @athlete] } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: "Update failed! " + e.message }
        format.json { render status: 404, json: { error: e.message, request: [@sport, @athlete] } }
      end
    end        
  end
  
  def destroy
    begin
      destroy_athlete(@athlete.id.to_s)
      @athlete.destroy    
            
      respond_to do |format|
        format.html { redirect_to sport_athletes_path(@sport) }
        format.json { render json: { successful: "delete successful", request: [@sport] } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to sport_athletes_path(@sport) }
        format.json { render status: 404, json: { error: e.message, request: [@sport] } }
      end
    end
  end
  
  def index
    begin
      @athletes = []
      
      if !params[:lastname].blank? && !params[:number].blank?
        players = Athlete.where(sport_id: params[:sport_id]).full_text_search(params[:lastname].to_s + " " + params[:number].to_s, match: :all)
      elsif !params[:lastname].blank?
        players = Athlete.where(sport_id: params[:sport_id]).full_text_search(params[:lastname].to_s).asc(:number)
      elsif !params[:number].blank?
        players = Athlete.where(sport_id: params[:sport_id]).full_text_search(params[:number].to_s)
      elsif params[:team_id]
        players = Athlete.where(sport_id: params[:sport_id], team_id: params[:team_id]).asc(:number)
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
    rescue Exception => e
      respond_to do |format|
        format.html { e.message }
        format.json { render status: 404, json: { error: e.message, request: [@sport] } }
      end
    end
  end
  
  def follow
    @athlete.fans.push(current_user.id)
    @athlete.save
    
    respond_to do |format|
      format.html { redirect_to [@sport, @athlete], notice: "Now following athlete " + @athlete.full_name }
      format.json { render json: { request: sport_athlete_url(@sport, @athlete) } }
    end
  end
  
  def unfollow
    @athlete.fans.delete(current_user.id)
    @athlete.save

    respond_to do |format|
      format.html { redirect_to :back, notice: "No longer following " + @athlete.full_name }
      format.json { render json: { request: sport_athlete_url(@sport, @athlete) } } 
    end
  end

  def stats
    if @sport.name == "Football"
      @stats = AthleteFootballStatsTotal.new
      @stats.passing_totals(@athlete)
      @ath_totals = @athlete.football_stats
      @stats.rushing_totals(@athlete)
      @stats.receiving_totals(@athlete)
      @stats.defense_totals(@athlete)
      @stats.specialteams_totals(@athlete)
    end
    respond_to do |format|
      format.json 
    end
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

    def destroy_athlete(athlete)
      @sport.photos.where(:players =>  athlete).each do |p|
        p.players.delete_if {|item| item == athlete }
        p.save
      end
      @sport.videoclips.where(players: athlete).each do |v|
        v.players.delete_if {|item| item == athlete }
        v.save
      end
    end
    
end

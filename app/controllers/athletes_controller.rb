class AthletesController < ApplicationController  
  include FootballStatistics

	before_filter	:authenticate_user!,	only: [:destroy, :update, :create, :edit, :playerstats, :new, :follow, :unfollow]
  before_filter :get_sport
  before_filter :correct_athlete,     only: [:show, :edit, :update, :destroy, :follow, :unfollow, :stats, :updatephoto, 
                                            :playerstats, :selectedstat]
  before_filter only: [:destroy, :update, :create, :edit, :new, :playerstats, :selectedstat] do |controller| 
    controller.SiteOwner?(@athlete.nil? ? nil : @athlete.team_id)
  end
  
  def new    
    @athlete = Athlete.new
    @height = []
    if @sport.sportname == "Football" or @sport.sportname == "Soccer"
      @position = []
    end
  end
  
  def create
    begin
      athlete = @sport.athletes.build(params[:athlete])

      if @sport.name == "Football"
        update_fbpostions(athlete)
      elsif @sport.name == "Soccer"
        update_soccer_positions(athlete)
      end

      update_height(athlete)
      athlete.fans = Array.new
      athlete.save!
      respond_to do |format|
        format.html { redirect_to [@sport, athlete], notice: 'Athlete created!'}
        format.json { render json: { athlete: athlete, request: [@sport, athlete] } }
      end
    rescue Exception => e
      respond_to do |format|   
        format.html { redirect_to :back, alert: "Error creating athlete " + e.message }
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
    if @sport.name == "Football" or @sport.name == "Soccer"
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
        update_fbpostions(@athlete)
      elsif @sport.name == "Soccer"
        update_soccer_positions(@athlete)
      end

      update_height(@athlete)
      @athlete.update_attributes!(params[:athlete])
      respond_to do |format|
          format.html { redirect_to [@sport, @athlete], notice: "Update successful" }
          format.json { render json: { athlete: @athlete, request: [@sport, @athlete] } }
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
      @athlete.newsfeeds = nil
      @athlete.blogs = nil
      @athlete.destroy    
            
      respond_to do |format|
        format.html { redirect_to sport_athletes_path(@sport) }
        format.json { render json: { successful: "delete successful", request: [@sport] } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to sport_athletes_path(@sport), alert: "Delete failed " + e.message }
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
        format.html { redirect_to :back, alert: e.message }
        format.json { render status: 404, json: { error: e.message, request: [@sport] } }
      end
    end
  end
  
  def follow
    @athlete.fans.push(current_user.id.to_s) unless @athlete.fans.include?(current_user.id.to_s)
    @athlete.save
    
    respond_to do |format|
      format.html { redirect_to [@sport, @athlete], notice: "Now following athlete " + @athlete.full_name }
      format.json { render json: { request: sport_athlete_url(@sport, @athlete) } }
    end
  end
  
  def unfollow
    @athlete.fans.delete(current_user.id.to_s)
    @athlete.save

    respond_to do |format|
      format.html { redirect_to :back, notice: "No longer following " + @athlete.full_name }
      format.json { render json: { request: sport_athlete_url(@sport, @athlete) } } 
    end
  end

  def mobilefollow
    begin
      @athlete.mobilefans.push(params[:token]) unless !@athlete.mobilefans.include?(params[:token])
      @athlete.save!
      
      respond_to do |format|
        format.json { render status: 200, json: { mobilefans: @athlete.mobilefans } }
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render status: 404, json: { error: e.message } }
      end
    end
  end

  def mobileunfollow
    begin
      @athlete.mobilefans.delete(params[:token]) if @athlete.mobilefans.include?(params[:token])
      @athlete.save!

      respond_to do |format|
        format.json { render status: 200, json: { mobilefans: @athlete.mobilefans } } 
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render status: 404, json: { error: e.message } }
      end
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

  def createathletephoto
    begin
      path = CGI.unescape(params[:filepath]).split('/')
      @athlete = @sport.athletes.find(path[4])    
      path = params[:filepath].split('/')
      imagepath = CGI.unescape(path[2])
      @athlete.processing = true

      @athlete.save!

      queue = @sport.photo_queues.new(modelid: @athlete.id, modelname: "athletes", filename: params[:filename], filetype: params[:filetype], filepath: imagepath)
      if queue.save!
        Resque.enqueue(PhotoProcessor, queue.id)
      end
    rescue Exception => e
      puts e.message
    end
  end

  def updatephoto
    begin    
      @athlete.processing = true

      @athlete.save!

      queue = @sport.photo_queues.new(modelid: @athlete.id, modelname: "athletes", filename: params[:filename], filetype: params[:filetype], 
                                      filepath: params[:filepath])
      if queue.save!
        Resque.enqueue(PhotoProcessor, queue.id)
      end

      respond_to do |format|
        format.json { render json: { success: "success", athlete: @athlete } }
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render status: 404, json: { error: e.message, athlete: @athlete } }
      end
    end
  end
  
  def playerstats
    if @sport.name == "Football"
      @statlist = ["Passing", "Rushing", "Receiving", "Defense", "Place Kicker", "Kicker", "Punter", "Returner"]

      passingstats = Passingstats.new(@sport, @athlete)
      @passingstats = passingstats.stats
      @passingtotals = passingstats.passingtotals

      rushingstats = Rushingstats.new(@sport, @athlete)
      @rushingstats = rushingstats.stats
      @rushingtotals = rushingstats.rushingtotals

      receivingstats = Receivingstats.new(@sport, @athlete)
      @receivingstats = receivingstats.stats
      @receivingtotals = receivingstats.receivingtotals

      defensestats = Defensestats.new(@sport, @athlete)
      @defensivestats = defensestats.stats
      @defensivetotals = defensestats.defensetotals

      placekickerstats = Placekickerstats.new(@sport, @athlete)
      @placekickerstats = placekickerstats.stats
      @placekickertotals = placekickerstats.placekickertotals

      returnerstats = Returnerstats.new(@sport, @athlete)
      @returnerstats = returnerstats.stats
      @returnertotals = returnerstats.returnertotals

      kickoffstats = Kickerstats.new(@sport, @athlete)
      @kickoffstats = kickoffstats.stats
      @kickofftotals = kickoffstats.kickertotals

      punterstats = Punterstats.new(@sport, @athlete)
      @punterstats = punterstats.stats
      @puntertotals = punterstats.puntertotals
    end
  end

  def selectedstat
    if @sport.name == "Football"
      if params[:selectedstat] == "Passing"
        redirect_to sport_athlete_football_passings_path(@sport, @athlete, gameschedule_id: params[:game])
      elsif params[:selectedstat] == "Rushing"
        redirect_to sport_athlete_football_rushings_path(@sport, @athlete, gameschedule_id: params[:game])
      elsif params[:selectedstat] == "Receiving"
        redirect_to sport_athlete_football_receivings_path(@sport, @athlete, gameschedule_id: params[:game])
      elsif params[:selectedstat] == "Defense"
        redirect_to sport_athlete_football_defenses_path(@sport, @athlete, gameschedule_id: params[:game])
      elsif params[:selectedstat] == "Returner"
        redirect_to sport_athlete_football_returners_path(@sport, @athlete, gameschedule_id: params[:game])
      elsif params[:selectedstat] == "Place Kicker"
        redirect_to sport_athlete_football_place_kickers_path(@sport, @athlete, gameschedule_id: params[:game])
      elsif params[:selectedstat] == "Punter"
        redirect_to sport_athlete_football_punters_path(@sport, @athlete, gameschedule_id: params[:game])
      elsif params[:selectedstat] == "Kicker"
        redirect_to sport_athlete_football_kickers_path(@sport, @athlete, gameschedule_id: params[:game])
      end
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

    def update_fbpostions(athlete)
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

    def update_soccer_positions(athlete)
      if !params[:soccer1_pos].nil? and !params[:soccer1_pos].blank?
        athlete.position = params[:soccer1_pos]
      end
      if !params[:soccer2_pos].nil? and !params[:soccer2_pos].blank?
        athlete.position = athlete.position + "/" + params[:soccer2_pos]
      end
      if !params[:soccer3_pos].nil? and !params[:soccer3_pos].blank?
        athlete.position = athlete.position + "/" + params[:soccer3_pos]
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

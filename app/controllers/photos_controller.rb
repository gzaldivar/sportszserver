class PhotosController < ApplicationController
  before_filter :authenticate_user!,	only: [:create, :edit, :newteam, :newathlete, :untagathlete, :untagteam, :update]
  before_filter :get_sport
  before_filter :correct_photo,       only: [:edit, :show, :destroy, :update]

  require 'base64'
  require 'openssl'
  require 'digest/sha1'

  def index
    @photos = []
    @athletes = []

    if !params[:team_id].nil? and !params[:team_id].blank?
      pics = @sport.photos.where(teamid: params[:team_id].to_s)
      @team = @sport.teams.find(params[:team_id].to_s)
    elsif !params[:team].nil? && !params[:team][:id].blank? && !params[:number].nil? && !params[:number][:id].blank? && 
          !params[:game].nil? && !params[:game][:id].blank?
      pics = @sport.photos.where(teamid: params[:team][:id].to_s, gameschedule: params[:game][:id].to_s, 
                                 :players.in => [params[:number][:id].to_s])
      @team = @sport.teams.find(params[:team][:id].to_s)
    elsif !params[:team].nil? && !params[:team][:id].blank? && !params[:athlete].nil? && !params[:athlete][:id].blank? && 
          !params[:game].nil? && !params[:game][:id].blank?
      pics = @sport.photos.where(teamid: params[:team][:id].to_s, gameschedule: params[:game][:id].to_s, 
                                 :players.in => [params[:athlete][:id].to_s])
      @team = @sport.teams.find(params[:team][:id].to_s)
    elsif !params[:team].nil? && !params[:team][:id].blank? && !params[:number].nil? && !params[:number][:id].blank?
      pics = @sport.photos.where(teamid: params[:team][:id].to_s, :players.in => [params[:number][:id].to_s])
      @team = @sport.teams.find(params[:team][:id].to_s)
    elsif !params[:team].nil? && !params[:team][:id].blank? && !params[:athlete].nil? && !params[:athlete][:id].blank?
      pics = @sport.photos.where(teamid: params[:team][:id].to_s, :players.in => [params[:athlete][:id].to_s])
      @team = @sport.teams.find(params[:team][:id].to_s)
    elsif !params[:team].nil? && !params[:team][:id].blank? && !params[:game].nil? && !params[:game][:id].blank?
      pics = @sport.photos.where(teamid: params[:team][:id].to_s, schedule: params[:game][:id].to_s)
      @team = @sport.teams.find(params[:team][:id].to_s)
    elsif !params[:team].nil? && !params[:team][:id].blank?
      pics = @sport.photos.where(teamid: params[:team][:id].to_s)
      @team = @sport.teams.find(params[:team][:id].to_s)
    elsif !params[:athlete].nil? and !params[:athlete][:id].blank?
      pics = @sport.photos.where(:players.in => [params[:athlete][:id].to_s])
      @athlete = @sport.athletes.find(params[:athlete][:id].to_s)
    elsif !params[:number].nil? && !params[:number][:id].blank?
      pics = @sport.photos.where(:players.in => [params[:number][:id].to_s])
      @athlete = @sport.athletes.find(params[:number][:id].to_s)
    else
      pics = []
    end
    
    if !pics.nil? and pics.any?
      pics.each_with_index do |p, cnt|
        @photos[cnt] = p
      end
    end

    respond_to do |format|
      format.html
      format.xml
      format.json 
      format.js
    end
  end
  
  def newschedule
    @gameschedule = Gameschedule.find(params[:id].to_s)
    team = @sport.teams.find(@gameschedule.team_id)
    @prefix = "t_" + team.id + "_g_" + @gameschedule.id + "_s_" + @sport.id
    
    time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
    time = time.to_time.yesterday.to_date.iso8601
    @photos = []
    
    @sport.photos.where(teamid: team.id, gameschedule: @gameschedule.id.to_s, :updated_at.gt => time, 
                        owner: current_user.id).asc(:updated_at).each_with_index do |q, cnt|
      @photos[cnt] = q
    end
    
    @id = @gameschedule.id
    
    respond_to do |format|
      format.html { render  'newphoto' }
      format.xml
      format.json 
      format.js
    end    
  end
  
  def newathlete
    @athlete = @sport.athletes.find(params[:id].to_s)
    @prefix = "t_" + @athlete.team_id + "_a_" + @athlete.id + "_s_" + @sport.id
    
    time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
    time = time.to_time.yesterday.to_date.iso8601
    @photos = []
    
    @sport.photos.where(teamid: @athlete.team_id, :players.in =>  [@athlete.id.to_s], :updated_at.gt => time, 
                        owner: current_user.id).asc(:updated_at).each_with_index do |q, cnt|
      @photos[cnt] = q
    end
    
    @id = @athlete.id
    
    respond_to do |format|
      format.html { render  'newphoto' }
      format.xml
      format.json 
      format.js
    end
  end
  
  def newteam
    @team = @sport.teams.find(params[:id].to_s)
    @prefix = "t_" + @team.id + "_s_" + @sport.id
    
    time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
    time = time.to_time.yesterday.to_date.iso8601
    @photos = []    
    @sport.photos.where(teamid: @team.id, :updated_at.gt => time, owner: current_user.id).asc(:updated_at).each_with_index do |q, cnt|
      @photos[cnt] = q
    end
    
    @id = @sport.id.to_s + @team.id.to_s
    
    respond_to do |format|
      format.html { render 'newphoto'}
      format.xml
      format.json 
      format.js
    end
  end
    
  def create    
    @photo = Photo.new
  
    @photo.filename = params[:filename]
    @photo.displayname = @photo.filename
    @photo.filepath = params[:filepath]
    @photo.filesize = params[:filesize]
    @photo.filetype = params[:filetype]
    @photo.original_url = params[:url]
    @photo.processing = true
    
    path = @photo.filepath.split('/')
    path = CGI.unescape(path[2])
    @photo.filepath = path
    
    s3 = AWS::S3.new
    bucket = s3.buckets[S3DirectUpload.config.bucket]
    obj = bucket.objects[@photo.filepath]
    @photo.original_url = obj.url_for(:read, expires:  473040000)
    
    data = @photo.filepath.split('/')
    data = data[data.length-2]
    tags = data.split('_')
    
    tags.each_with_index do |t, cnt|
      case t
      when "t"
        @photo.teamid = tags[cnt+=1]
      when "s"
        @photo.sport = tags[cnt+=1]
      when "a"
        @photo.players = Array.new
        @photo.players.push(tags[cnt+=1])
      when "g"
        @photo.gameschedule_id = tags[cnt+=1]
      end
    end
            
    # put review logic here !!!!!!!
    
    if user_signed_in?
      @photo.user_id = current_user.id
    end
    
    if @photo.save!
      queue = @sport.photo_queues.new(modelid: @photo.id, modelname: "photos")
      if queue.save!
        Resque.enqueue(PhotoProcessor, queue.id)
      else
        flash[:alert] = "Error putting photo in queue!"
      end
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.xml
      format.json 
      format.js
    end
  end
  
  def updategameschedule
    @gameschedules = @sport.teams.find(params[:teamid]).gameschedules
  end
  
  def edit
    @athletes = []
    if @photo.teamid.nil?
      ath = @sport.athletes
    else
      ath = @sport.athletes.where(team: @photo.teamid)
    end
    ath.each_with_index do |a, cnt|
      @athletes[cnt] = a
    end
    @athlete_tags = []
    if !@photo.players.nil? and @photo.players.any?
      @photo.players.each_with_index do |p, cnt|
        @athlete_tags[cnt] = Athlete.find(p)
      end
    end
    @teams = @sport.teams
    @gameschedules = []
#    @teams.each do |t|
      @teams.first.gameschedules.each_with_index do |g, cnt|
        @gameschedules[cnt] = g
      end
    end
#  end
  
  def update
    if @photo.update_attributes(params[:photo])
      if @photo.players.nil?
        @photo.players = Array.new
      end
      if !params[:athlete][:id].blank?
        @photo.players.push(params[:athlete][:id].to_s)
        @photo.save!
      end
    
      respond_to do |format|
        format.html { redirect_to [@sport, @photo], notice: "Update successful!" }
        format.xml
        format.json 
        format.js
      end
    else
      redirect_to [@sport, @photo], alert: "Update failed!"
    end
  end
  
  def destroy
    @photo.deletephoto
    @photo.delete
    redirect_to sport_photos_path(@sport), notice: "Photo deleted!"
  end
  
  def untagathlete
    @photo = Photo.find(params[:photo][:id])
    if params[:athlete][:name]
      @photo.players.delete(params[:athlete][:name])
    end
    @photo.save!

    respond_to do |format|
      format.html { redirect_to [@sport, @photo], notice: "Athlete untagged from photo!" }
      format.xml
      format.json 
      format.js
    end
  end
  
  def untagteam
    if params[:team] && params[:id]
      @photo.team = nil
      @photo.players.clear
    end
    @photo.save!
    
    respond_to do |format|
      format.html { redirect_to [@sport, @photo], notice: "Team untagged from photo:" }
      format.xml
      format.json 
      format.js
    end
  end
  
  def slideshow
  end
  
  private
  
    # generate the policy document that amazon is expecting.
    def s3_upload_policy_document
      Base64.encode64(policy_data.to_json).gsub("\n", "")
    end
    
    def policy_data
      {
        expiration: 10.hours.from_now.utc.iso8601,
        conditions: [
          ["starts-with", "$utf8", ""],
          ["starts-with", "$key", "uploads/"],
          ["starts-with", "$Content-Type", ""],
          ["content-length-range", 0, 20.megabytes],
          { bucket: "sportsite_solutions" },
          { acl: 'public-read' },
          { success_action_status: '200' }
          ]
        }    
    end
  
    # sign our request by Base64 encoding the policy document.
    def s3_upload_signature
      Base64.encode64(
        OpenSSL::HMAC.digest(
          OpenSSL::Digest::Digest.new('sha1'),
          AWS.config.secret_access_key,
          s3_upload_policy_document
        )
      ).gsub("\n", "")
    end
    
    def get_sport
      @sport = Sport.find(params[:sport_id])
    end
    
    def correct_photo
      @photo = Photo.find(params[:id])
    end
    
end

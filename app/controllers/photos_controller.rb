class PhotosController < ApplicationController
  before_filter :authenticate_user!,	only: [:destroy, :create, :edit, :newteam, :newathlete, :untagathlete, :untagteam, :update, :untag_athletes, 
                                            :tag_athletes, :createmobile]
  before_filter :get_sport
  before_filter :correct_photo,       only: [:edit, :show, :destroy, :update, :errors, :clear_error, :approval, :untag_athletes, :tag_athletes]
  before_filter only: [:destroy, :update, :create, :edit, :newteam, :newathlete, :untagathlete, :untagteam, :update, :untag_athletes, :tag_athletes, :createmobile] do |controller| 
    controller.team_manager?(@athlete, nil)
  end

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
      pics = @sport.photos.where(teamid: params[:team][:id].to_s, gameschedule: params[:game][:id].to_s)
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
    elsif !params[:username].nil? and !params[:username].blank?
      pics = @sport.photos.where(user_id: current_user.id.to_s)
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
    if roomformedia?(@sport)
      @gameschedule = Gameschedule.find(params[:id].to_s)
      team = @sport.teams.find(@gameschedule.team_id)
      @prefix = "t_" + team.id + "_g_" + @gameschedule.id + "_s_" + @sport.id
      
#      time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
      time = DateTime.now.beginning_of_day.iso8601
      time = time.to_time.yesterday.to_date.iso8601
      @photos = []
      
      @sport.photos.where(teamid: team.id, gameschedule: @gameschedule.id.to_s, :updated_at.gt => time, 
                          user_id: current_user.id).asc(:updated_at).each_with_index do |q, cnt|
        @photos[cnt] = q
      end
      
      @id = @gameschedule.id
      
      respond_to do |format|
        format.html { render  'newphoto' }
        format.xml
        format.json 
        format.js
      end
    else
      redirect_to :back, alert: "You have exceeded your space allotment for media. Conisder upgradig or delete some media."
    end
  end
  
  def newathlete
    if roomformedia?(@sport)
      @athlete = @sport.athletes.find(params[:id].to_s)
      @prefix = "t_" + @athlete.team_id + "_a_" + @athlete.id + "_s_" + @sport.id
      
#      time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
      time = DateTime.now.beginning_of_day.iso8601
      time = time.to_time.yesterday.to_date.iso8601
      @photos = []
      
      @sport.photos.where(teamid: @athlete.team_id, :players.in =>  [@athlete.id.to_s], :updated_at.gt => time, 
                          user_id: current_user.id).asc(:updated_at).each_with_index do |q, cnt|
        @photos[cnt] = q
      end
      
      @id = @athlete.id
      
      respond_to do |format|
        format.html { render  'newphoto' }
        format.xml
        format.json 
        format.js
      end
    else
      redirect_to :back, alert: "You have exceeded your space allotment for media. Conisder upgradig or delete some media."
    end
  end
  
  def newteam
    if roomformedia?(@sport)
      @team = @sport.teams.find(params[:id].to_s)
      @prefix = "t_" + @team.id + "_s_" + @sport.id
      
#      time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
      time = DateTime.now.beginning_of_day.iso8601
      time = time.to_time.yesterday.to_date.iso8601
      @photos = []    
      @sport.photos.where(teamid: @team.id, :updated_at.gt => time, user_id: current_user.id).asc(:updated_at).each_with_index do |q, cnt|
        @photos[cnt] = q
      end
      
      @id = @sport.id.to_s + @team.id.to_s
      
      respond_to do |format|
        format.html { render 'newphoto'}
        format.xml
        format.json 
        format.js
      end
    else
      redirect_to :back, alert: "You have exceeded your space allotment for media. Conisder upgradig or delete some media."
    end
  end

  def createmobile
    begin
      photo = @sport.photos.build(params[:photo])
      photo.processing = true
      
      s3 = AWS::S3.new
      bucket = s3.buckets[S3DirectUpload.config.bucket]
      obj = bucket.objects[photo.filepath]
      photo.original_url = obj.url_for(:read, expires:  473040000)

      puts photo.filepath
      puts photo.original_url

      if @sport.review_media?
        photo.pending = true
      else
        photo.pending = false
      end

      photo.save!

      queue = @sport.photo_queues.new(modelid: photo.id, modelname: "photos")
      queue.save!

      puts "addded to queue"
      puts photo.id

      Resque.enqueue(PhotoProcessor, queue.id)

      render status: 200, json: { photo: @photo, request: [@sport, photo] }
    rescue Exception => e
      render status: 404, json: { error: e.message, request: @sport }
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
            
    if @sport.review_media?
      @photo.pending = true
    else
      @photo.pending = false
    end
    
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
      respond_to do |format|
        format.html
        format.json
      end
    else
      respond_to do |format|
        format.html
        format.json
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
    begin 
      @photo.update_attributes(params[:photo])
      if @photo.players.nil?
        @photo.players = Array.new
      end
      if !params[:athlete].nil? and !params[:athlete][:id].blank?
        unless @photo.players.include?(params[:athlete][:id].to_s)
          @photo.players << params[:athlete][:id].to_s
        end
#        @photo.players.push(params[:athlete][:id].to_s)
        @photo.save!
      end
    
      respond_to do |format|
        format.html { redirect_to [@sport, @photo], notice: "Update successful!" }
        format.xml
        format.json { render json: { photo: @photo, request: [@sport, @photo] } }
        format.js
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to [@sport, @photo], alert: "Update failed!" }
        format.json { render status: 404, json: { error: e.message, request: [@sport, @photo] } }
      end
    end
  end
  
  def destroy
    @sport.mediasize = @sport.mediasize - @photo.thumbsize - @photo.mediumsize - @photo.largesize
    @sport.save
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
      format.json { render json: { photo: @photo, request: [@sport, @photo] } }
      format.js
    end
  end

  def untag_athletes
    begin
      params[:photo].each do |key, values|
        @photo.players.delete(values.to_s)
      end
      @photo.save!

      respond_to do |format|
        format.json { render json: { photo: @photo, request: [@sport, @photo] } }
      end
    rescue Exception => e
      respond_to do |format|
        format.json {  render status: 404, json: { error: e.message, request: [@sport, @photo] } }
      end
    end
  end

  def tag_athletes
    begin
      params[:photo].each do |key, values|
        if @photo.players.nil?
          @photo.players = Array.new
        end
        unless @photo.players.include?(values.to_s)
          @photo.players << values.to_s
        end
        @photo.save!
        respond_to do |format|
          format.json { render json: { photo: @photo, request: sport_photos_path(@sport, @photo) } }
        end
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render status: 404, json: { error: e.message, request: sport_photos_path(@sport, @photo) } }
      end
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
  
  def errors
    @error = @sport.photo_errors.find_by(modelid: @photo.id)
  end

  def clear_error
    @sport.photo_errors.find_by(modelid: @photo.id).destroy
    @photo.destroy
    redirect_to sport_photos_path(@sport), notice: "Photo Error cleared!"
  end

  def approval
    @photo.pending = false
    @photo.save
    redirect_to sport_photos_path(@sport)
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

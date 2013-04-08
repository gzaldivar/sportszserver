class VideoclipsController < ApplicationController
	before_filter :authenticate_user!,	only: [:edit, :update, :destroy, :newathlete, :newteam, :newgame, :create]
	before_filter :get_sport
	before_filter :correct_video, 		only: [:edit, :update, :destroy, :show]
  
  def newathlete
    @athlete = @sport.athletes.find(params[:id].to_s)
    @prefix = "t_" + @athlete.team + "_a_" + @athlete.id + "_s_" + @sport.id
    
    time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
    time = time.to_time.yesterday.to_date.iso8601
    @videoclips = []
    
    @sport.videoclips.where(teamid: @athlete.team, :players.in =>  [@athlete.id.to_s], :updated_at.gt => time, 
                            owner: current_user.id).asc(:updated_at).each_with_index do |q, cnt|
      @videoclips[cnt] = q
    end
    
    @id = @athlete.id
    
    respond_to do |format|
      format.html { render  'newvideo' }
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
    @videoclips = []    
    @sport.videoclips.where(teamid: @team.id, :updated_at.gt => time, owner: current_user.id).asc(:updated_at).each_with_index do |q, cnt|
      @videoclips[cnt] = q
    end
    
    @id = @sport.id.to_s + @team.id.to_s
    
    respond_to do |format|
      format.html { render 'newvideo'}
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
    @videoclips = []
    
    @sport.videoclips.where(teamid: team.id, schedule: @gameschedule.id.to_s, :updated_at.gt => time, 
                            owner: current_user.id).asc(:updated_at).each_with_index do |q, cnt|
      @videoclips[cnt] = q
    end
    
    @id = @gameschedule.id
    
    respond_to do |format|
      format.html { render  'newvideo' }
      format.xml
      format.json 
      format.js
    end    
  end

  def create
    @videoclip = Videoclip.new
    @videoclip.filepath = params[:filepath]
    @videoclip.filename = params[:filename]
    @videoclip.displayname = @videoclip.filename
    @videoclip.filesize = params[:filesize]
    @videoclip.filetype = params[:filetype]
    @videoclip.video_url = params[:url]
  
    path = @videoclip.filepath.split('/')
    path = CGI.unescape(path[2])
    @videoclip.filepath = path

    s3 = AWS::S3.new
    bucket = s3.buckets[S3DirectUpload.config.bucket]
    obj = bucket.objects[@videoclip.filepath]

    # Check to see if video correct format, length, etc. 

    video_path = @videoclip.videopath + "/" + SecureRandom.hex(10) + @videoclip.filename
      
    File.open(video_path, 'wb') do |file|
      obj.read do |chunk|
        file.write(chunk)
      end
    end

    movie = FFMPEG::Movie.new(video_path)

    if !movie.nil?
      if movie.video_codec != nil
        str = movie.video_codec.split(" ")
        if str[0] != "h264"
          @videoclip.error_status = true
          @videoclip.error_message = "Uploaded video is not an h264 video"
        else
          if movie.audio_codec != nil
            str = movie.audio_codec.split(" ")
            if str[0] != "aac"
              @videoclip.error_status = true
              @videoclip.error_message = "Audio for video clip is not AAC"
            end
          end
          @videoclip.duration = movie.duration
          @videoclip.bitrate = movie.bitrate
          @videoclip.height = movie.height
          @videoclip.width = movie.width
          @videoclip.size = movie.size
          @videoclip.frame_rate = movie.frame_rate
          @videoclip.resolution = movie.resolution

        end
      else
        @videoclip.error_status = true
        @videoclip.error_message = "Unrecognized video codec."
      end
    else
      @videoclip.error_status = true
      @videoclip.error_message = "Uploaded media is not playable"
    end

    if !@videoclip.error_status
      data = @videoclip.filepath.split('/')
      data = data[data.length-2]
      tags = data.split('_')
      
      tags.each_with_index do |t, cnt|
        case t
        when "t"
          @videoclip.teamid = tags[cnt+=1]
        when "s"
          @videoclip.sport = tags[cnt+=1]
        when "a"
          @videoclip.players = Array.new
          @videoclip.players.push(tags[cnt+=1])
        when "g"
          @videoclip.schedule = tags[cnt+=1]
        end
      end
              
      # put review logic here !!!!!!!
      
      if user_signed_in?
        @videoclip.owner = current_user.id
      end
     
      filepath = "videos/" + @videoclip.id + "/" + SecureRandom.hex(10)
      @videoclip.filepath = filepath + @videoclip.filename
      newobj = obj.move_to(@videoclip.filepath)
      @videoclip.video_url = newobj.url_for(:read, expires:  473040000)

      # create poster for video clip

      poster_path = @videoclip.videopath + "/" + SecureRandom.hex(10) + "temp_poster.jpg"
      poster = movie.screenshot(poster_path)
      @videoclip.poster_filepath = "videos/" + @videoclip.id + "/" + SecureRandom.hex(10) + "poster.jpg"
      posterobj = bucket.objects[@videoclip.poster_filepath]
      posterobj.write(Pathname.new(poster_path))   
      @videoclip.poster_url = posterobj.url_for(:read, expires:  473040000)
      @videoclip.save

      FileUtils.rm(poster_path)
    end
    
    FileUtils.rm(video_path)
  end

  def index
    @videoclips = []
    @athletes = []

    if !params[:team_id].nil? and !params[:team_id].blank?
      clips = @sport.videoclips.where(teamid: params[:team_id].to_s)
      @team = @sport.teams.find(params[:team_id].to_s)
    elsif !params[:team].nil? && !params[:team][:id].blank? && !params[:number].nil? && !params[:number][:id].blank? && 
          !params[:game].nil? && !params[:game][:id].blank?
      pics = @sport.videoclips.where(teamid: params[:team][:id].to_s, schedule: params[:game][:id].to_s, 
                                 :players.in => [params[:number][:id].to_s])
      @team = @sport.teams.find(params[:team][:id].to_s)
    elsif !params[:team].nil? && !params[:team][:id].blank? && !params[:athlete].nil? && !params[:athlete][:id].blank? && 
          !params[:game].nil? && !params[:game][:id].blank?
      pics = @sport.videoclips.where(teamid: params[:team][:id].to_s, schedule: params[:game][:id].to_s, 
                                 :players.in => [params[:athlete][:id].to_s])
      @team = @sport.teams.find(params[:team][:id].to_s)
    elsif !params[:team].nil? && !params[:team][:id].blank? && !params[:number].nil? && !params[:number][:id].blank?
      clips = @sport.videoclips.where(teamid: params[:team][:id].to_s, :players.in => [params[:number][:id].to_s])
      @team = @sport.teams.find(params[:team][:id].to_s)
    elsif !params[:team].nil? && !params[:team][:id].blank? && !params[:athlete].nil? && !params[:athlete][:id].blank?
      clips = @sport.videoclips.where(teamid: params[:team][:id].to_s, :players.in => [params[:athlete][:id].to_s])
      @team = @sport.teams.find(params[:team][:id].to_s)
    elsif !params[:team].nil? && !params[:team][:id].blank? && !params[:game].nil? && !params[:game][:id].blank?
      pics = @sport.videoclips.where(teamid: params[:team][:id].to_s, schedule: params[:game][:id].to_s)
      @team = @sport.teams.find(params[:team][:id].to_s)
    elsif !params[:team].nil? && !params[:team][:id].blank?
      clips = @sport.videoclips.where(teamid: params[:team][:id].to_s)
      @team = @sport.teams.find(params[:team][:id].to_s)
    elsif !params[:athlete].nil? and !params[:athlete][:id].blank?
      clips = @sport.videoclips.where(:players.in => [params[:athlete][:id].to_s])
    elsif !params[:number].nil? && !params[:number][:id].blank?
      clips = @sport.videoclips.where(:players.in => [params[:number][:id].to_s])
    else
      clips = []
    end
    
    if !clips.nil? and clips.any?
      clips.each_with_index do |p, cnt|
        @videoclips[cnt] = p
      end
    end

    respond_to do |format|
      format.html
      format.xml
      format.json 
      format.js
    end    
  end
  
  def show
    
  end
  
  def updategameschedule
    @gameschedules = @sport.teams.find(params[:teamid]).gameschedules
    render 'photos/updategameschedule'    
  end
  
  def edit
    @athletes = []
    if @videoclip.teamid.nil?
      ath = @sport.athletes
    else
      ath = @sport.athletes.where(team: @videoclip.teamid)
    end
    ath.each_with_index do |a, cnt|
      @athletes[cnt] = a
    end
    @athlete_tags = []
    if !@videoclip.players.nil? and @videoclip.players.any?
      @videoclip.players.each_with_index do |p, cnt|
        @athlete_tags[cnt] = Athlete.find(p)
      end
    end
    @teams = @sport.teams
    @gameschedules = []
#    @teams.each do |t|
      @teams.first.gameschedules.each_with_index do |g, cnt|
        @gameschedules[cnt] = g
      end
#    end
  end
  
  def update
    if @videoclip.update_attributes(params[:videoclip])
      if @videoclip.players.nil?
        @videoclip.players = Array.new
      end
      if !params[:athlete][:id].blank?
        @videoclip.players.push(params[:athlete][:id].to_s)
        @videoclip.save!
      end
    
      respond_to do |format|
        format.html { redirect_to [@sport, @videoclip], notice: "Update successful!" }
        format.xml
        format.json 
        format.js
      end
    else
      redirect_to [@sport, @videoclip], error: "Update failed!"
    end
  end

  def destroy
  	begin
	  	@videoclip.deleteclips
	  	@videoclip.destroy
	  	redirect_to sport_videoclips_path(@sport), notice: "Videoclip delete sucessful!"
	  rescue => e
	  	redirect_to :back, error: "Error deleting video " + e.message
	  end
  end

  def untagathlete
    @videoclip = Videoclip.find(params[:videoclip][:id])
    if params[:athlete][:name]
      @videoclip.players.delete(params[:athlete][:name])
    end
    @videoclip.save!

    respond_to do |format|
      format.html { redirect_to [@sport, @videoclip], notice: "Athlete untagged from video clip!" }
      format.xml
      format.json 
      format.js
    end
  end
  
  def untagteam
    if params[:team] && params[:id]
      @videoclip.team = nil
      @videoclip.players.clear
    end
    @videoclip.save!
    
    respond_to do |format|
      format.html { redirect_to [@sport, @videoclip], notice: "Team untagged from video clip:" + @videoclip.displayname}
      format.xml
      format.json 
      format.js
    end
  end
  
  private

  	def get_sport
  		@sport = Sport.find(params[:sport_id])
  	end

  	def correct_video
  		@videoclip = Videoclip.find(params[:id])
  	end
  
end

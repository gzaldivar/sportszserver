class VideoclipsController < ApplicationController
	before_filter :authenticate_user!,	only: [:edit, :update, :destroy, :newathlete, :newteam, :newgame, :create, :tag_athletes, 
                                             :untag_athletes, :untagathlete, :untagteam, :createclient]
	before_filter :get_sport
	before_filter :correct_video, 		only: [:edit, :update, :destroy, :show, :untag_athletes, :tag_athletes]
  before_filter only: [:destroy, :update, :create, :edit, :newteam, :newathlete, :untagathlete, :untagteam, :update, :untag_athletes, :tag_athletes, :createmobile] do |controller| 
    controller.SiteOwner?(@videoclip.nil? ? nil : @videoclip.team_id)
  end
  before_filter do |controller|
    controller.packageEnabled?(current_site)
  end
  
  def videoclipshome
    if !current_team.featuredvideoclips.nil?
      @featuredlists = @sport.videoclips.where(team_id: current_team.id.to_s, 
                                          :id.in => current_team.featuredvideoclips).desc(:updated_at).paginate(per_page: 10)
      @thevideo = @featuredlists[0]
    else
      @videolists = @sport.videoclips.where(team_id: current_team.id.to_s).desc(:updated_at).paginate(per_page: 10)
      puts @videolists.count
      if @videolists.any?
        @thevideo = @videolists[0]
      else
        @thevideo = Videoclip.new(displayname: 'No Videos')
      end
    end

    @gameschedules = current_team.gameschedules.asc(:gamedate)
    @athletes = @sport.athletes.where(team_id: current_team.id).asc(:number)
    @gamelogs = []
  end

  def showfeaturedvideos
    puts params[:team_id]
    @team = current_team? ? current_team : @sport.teams.find(params[:team_id])
    puts @team.mascot
    if !@team.featuredvideoclips.nil?
      @featuredlists = @sport.videoclips.where(team_id: @team.id, :id.in => @team.featuredvideoclips).desc(:updated_at).paginate(per_page: 10)
    else
      @featuredlists = nil
    end
    respond_to do |format|
      format.js
      format.json
    end
  end

  def latest
    @videolists = @sport.videoclips.where(team_id: current_team.id.to_s).desc(:updated_at).paginate(per_page: 10)
    respond_to do |format|
      format.js
    end
  end

  def displayvideo
    @video = @sport.videoclips.find(params[:videoclip_id])
  end

  def featuredvideo
    @team = current_team? ? current_team : @sport.teams.find(params[:team_id])
    @athletes = @sport.athletes.where(team_id: @team.id)
    @gameschedules = @team.gameschedules
    @gamelogs = []

    if params[:athlete_id] and !params[:athlete_id].blank? and params[:gameschedule_id] and !params[:gameschedule_id].blank?
      @videoclips = @sport.videoclips.where(team_id: @team.id, players: params[:athlete_id], 
                gameschedule_id: params[:gameschedule_id]).desc(:updated_at).paginate(per_page: 10, :page=>params[:page])
    elsif params[:athlete_id] and !params[:athlete_id].blank?
      @videoclips = @sport.videoclips.where(team_id: @team.id, players: params[:athlete_id]).desc(:updated_at).paginate(per_page: 10, :page=>params[:page])
    elsif params[:gameschedule_id] and !params[:gameschedule_id].blank?
      @videoclips = @sport.videoclips.where(team_id: @team.id, gameschedule_id: params[:gameschedule_id]).desc(:updated_at).paginate(per_page: 10, :page=>params[:page])
    elsif params[:username].to_i == 1
      @videoclips = @sport.videoclips.where(user_id: current_user.id).desc(:updated_at).paginate(per_page: 10, :page=>params[:page])
    else
      @videoclips = @sport.videoclips.where(team_id: @team.id).desc(:updated_at).paginate(per_page: 10, :page=>params[:page])
    end

    if @team.featuredvideoclips.nil?
      @featuredvideoclips = nil
    else
      @featuredvideoclips = @sport.videoclips.where(team_id: @team.id, :id.in => @team.featuredvideoclips).desc(:updated_at)
    end
  end

  def updatefeaturedvideoclipslist
    if current_team.featuredvideoclips.nil?
      current_team.featuredvideoclips = Array.new
    end

    if !params[:videoselect_ids].nil?
      params[:videoselect_ids].each do |values|
        if !current_team.featuredvideoclips.include?(values)
          current_team.featuredvideoclips << values
        end
      end
    end

    current_team.save!

    redirect_to featuredvideo_sport_videoclips_path(@sport)
  end

  def deletefeaturedvideoclips
    if !params[:video_ids].nil?
      params[:video_ids].each do |p|
        current_team.featuredvideoclips.delete(p)
      end
    end

    current_team.save!

    redirect_to featuredvideo_sport_videoclips_path(@sport)
  end

  def updatefeaturedvideos
    if !params[:video_ids].nil?
        @team = current_team? ? current_team : @sport.teams.find(params[:team_id])

        if @team.featuredvideoclips.nil?
          @team.featuredvideoclips = Array.new
        end

        params[:video_ids].each do |values|
          if !@team.featuredvideoclips.include?(values)
            @team.featuredvideoclips << values
          end
        end

        if !@team.featuredvideoclips.nil? and !@team.featuredvideoclips.empty?
          @team.featuredvideoclips.each do |f|
            found = false
            params[:video_ids].each do |p|
              if f == p
                found = true
                break
              end
            end
            if !found
              @team.featuredvideoclips.delete(f)
            end
          end
        end

        if @team.featuredvideoclips.count == 0
          @team.featuredvideoclips = nil
        end
        
      @team.save!
    end

    respond_to do |format|
      format.html { redirect_to videoclipshome_sport_videoclips_path(@sport), notice: "Featured photos added!" }
      format.json { render status: 200, json: { success: "success" } }
    end
  end

  def newathlete
    if roomformedia?(@sport)
      @athlete = @sport.athletes.find(params[:athlete_id].to_s)
      @prefix = "t_" + @athlete.team_id + "_a_" + @athlete.id + "_s_" + @sport.id
      
      time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
      time = time.to_time.yesterday.to_date.iso8601
      @videoclips = []
      
      @sport.videoclips.where(team_id: @athlete.team_id, :players.in =>  [@athlete.id.to_s], :updated_at.gt => time, 
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
    else
      redirect_to :back, alert: "You have exceeded your space allotment for media. Conisder upgradig or delete some media."
    end
  end

  def newteam
    if roomformedia?(@sport)
      @team = @sport.teams.find(params[:team_id].to_s)
      @prefix = "t_" + @team.id + "_s_" + @sport.id
      
      time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
      time = time.to_time.yesterday.to_date.iso8601
      @videoclips = []    
      @sport.videoclips.where(team_id: @team.id, :updated_at.gt => time, owner: current_user.id).asc(:updated_at).each_with_index do |q, cnt|
        @videoclips[cnt] = q
      end
      
      @id = @sport.id.to_s + @team.id.to_s
      
      respond_to do |format|
        format.html { render 'newvideo'}
        format.xml
        format.json 
        format.js
      end  	
    else
      redirect_to :back, alert: "You have exceeded your space allotment for media. Conisder upgradig or delete some media."
    end
  end

  def newschedule
    if roomformedia?(@sport)
      @gameschedule = Gameschedule.find(params[:gameschedule_id].to_s)
      team = @sport.teams.find(@gameschedule.team_id)
      @prefix = "t_" + team.id + "_g_" + @gameschedule.id + "_s_" + @sport.id
      
      time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
      time = time.to_time.yesterday.to_date.iso8601
      @videoclips = []
      
      @sport.videoclips.where(team_id: team.id, gameschedule: @gameschedule.id.to_s, :updated_at.gt => time, 
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
    else
      redirect_to :back, alert: "You have exceeded your space allotment for media. Conisder upgradig or delete some media."
    end
  end

  def createclient
    begin
      video = @sport.videoclips.create!(params[:videoclip])
      createNewsItem(video)
      respond_to do |format|
        format.json { render json: { videoclip: video } }
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render json: { error: e.message } }
      end
    end
 end

  def create
    begin
      @videoclip = Videoclip.new
      @videoclip.filepath = params[:filepath]
      @videoclip.filename = params[:filename]
      @videoclip.displayname = @videoclip.filename
      @videoclip.description = ""
      @videoclip.filesize = params[:filesize]
      @videoclip.filetype = params[:filetype]
      @videoclip.video_url = params[:url]
    
      if params[:team_id].nil? || params[:team_id].blank?
        path = @videoclip.filepath.split('/')
        path = CGI.unescape(path[2])
        @videoclip.filepath = path
      end

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
          puts str[0]
          if str[0] != "h264"
            @videoclip.error_status = true
            @videoclip.error_message = "Uploaded video is not an h264 video"
          else
            if movie.audio_codec != nil
              str = movie.audio_codec.split(" ")
              puts str[0]
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

#            if @videoclip.duration > 24.0
#              @videoclip.error_status = true
#              @videoclip.error_message = "Video clip exceeds maximum duration of 24 seconds"
#            end

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
        
        if params[:team_id].nil? || params[:team_id].blank?
          tags.each_with_index do |t, cnt|
            case t
            when "t"
              @videoclip.team_id = tags[cnt+=1]
            when "s"
              @videoclip.sport = tags[cnt+=1]
            when "a"
              @videoclip.players = Array.new
              @videoclip.players.push(tags[cnt+=1])
            when "g"
              @videoclip.gameschedule_id = tags[cnt+=1]
            end
          end
        else
          if !params[:gameschedule_id].nil? and !params[:gameschedule_id].blank?
            @videoclip.gameschedule_id = params[:gameschedule_id]
          end
          @videoclip.team_id = params[:team_id]
        end
                
        if @sport.review_media?
          @videoclip.pending = true
        else
          @videoclip.pending = false
        end
        
        if user_signed_in?
          @videoclip.user_id = current_user.id
        elsif !params[:user_id].nil? and !params[:user_id].blank?
          @videoclip.user_id = params[:user_id].to_s
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
        @sport.mediasize = @sport.mediasize + @videoclip.size
        @sport.save
        @videoclip.save!

        createNewsItem(@videoclip)
        FileUtils.rm(poster_path)
      else
        FileUtils.rm(video_path)
        obj.delete
        raise "Error Processing Video " + @videoclip.error_message
      end
      
      respond_to do |format|
          format.js
          format.json { render json: { videoclip: @videoclip } }
      end

      FileUtils.rm(video_path)
    rescue Exception => e
      puts e.message
      respond_to do |format|
        format.js
        format.json { render status: 404, json: { error: e.message, request: @sport } }
      end
    end

  end

  def createmobile
    begin
      video = @sport.videoclips.build(params[:videoclip])
      
      s3 = AWS::S3.new
      bucket = s3.buckets[S3DirectUpload.config.bucket]
      obj = bucket.objects[video.filepath]
      video.video_url = obj.url_for(:read, expires:  473040000)

      puts video.filepath
      puts video.video_url

      video_path = video.videopath + "/" + SecureRandom.hex(10) + video.filename
        
      File.open(video_path, 'wb') do |file|
        obj.read do |chunk|
          file.write(chunk)
        end
      end

      movie = FFMPEG::Movie.new(video_path)

      if !movie.nil?
        if movie.video_codec != nil
          str = movie.video_codec.split(" ")
          puts str[0]
          if str[0] != "h264"
            video.error_status = true
            video.error_message = "Uploaded video is not an h264 video"
          else
            if movie.audio_codec != nil
              str = movie.audio_codec.split(" ")
              puts str[0]
              if str[0] != "aac"
                video.error_status = true
                video.error_message = "Audio for video clip is not AAC"
              end
            end
            video.duration = movie.duration
            video.bitrate = movie.bitrate
            video.height = movie.height
            video.width = movie.width
            video.size = movie.size
            video.frame_rate = movie.frame_rate
            video.resolution = movie.resolution

#            if video.duration > 24.0
#              video.error_status = true
#              video.error_message = "Video clip exceeds maximum duration of 24 seconds"
#            end

          end
        else
          video.error_status = true
          video.error_message = "Unrecognized video codec."
        end
      else
        video.error_status = true
        video.error_message = "Uploaded media is not playable"
      end

      if !video.error_status
        if user_signed_in?
          video.user_id = current_user.id
        elsif !params[:user_id].nil? and !params[:user_id].blank?
          video.user_id = params[:user_id].to_s
        end
       
        filepath = "videos/" + video.id + "/" + SecureRandom.hex(10)
        video.filepath = filepath + video.filename
        newobj = obj.move_to(video.filepath)
        video.video_url = newobj.url_for(:read, expires:  473040000)

        # create poster for video clip

        poster_path = video.videopath + "/" + SecureRandom.hex(10) + "temp_poster.jpg"
        poster = movie.screenshot(poster_path)
        video.poster_filepath = "videos/" + video.id + "/" + SecureRandom.hex(10) + "poster.jpg"
        posterobj = bucket.objects[video.poster_filepath]
        posterobj.write(Pathname.new(poster_path))   
        video.poster_url = posterobj.url_for(:read, expires:  473040000)
        @sport.mediasize = @sport.mediasize + video.size
        @sport.save
        video.save!

        createNewsItem(video)
      else
        FileUtils.rm(video_path)
        obj.delete
        raise "Error Processing Video " + video.error_message
      end

      FileUtils.rm(poster_path)
      FileUtils.rm(video_path)
     render status: 200, json: { videoclip: video, request: [@sport, video] }
    rescue Exception => e
      render status: 404, json: { error: e.message, request: @sport }
    end
  end

  def index
      @videoclips = []
      @athletes = []

      if params[:team_id] or current_team
        @team = params[:team_id] ? @sport.teams.find(params[:team_id]) : @sport.teams.find(current_team.id)
        @gameschedules = @team.gameschedules
      end

      if params[:all].to_i == 1
        
        @videoclips = @sport.videoclips.where(team_id: @team.id).desc(:updated_at).paginate(per_page: 10, page: params[:page])

      elsif params[:username].to_i == 1 

        @videoclips = @sport.videoclips.where(team_id: @team.id).and(user_id: current_user.id).desc(:updated_at).paginate(per_page: 10, page: params[:page])

      elsif !params[:athlete_id].blank? and !params[:gameschedule_id].blank? and !params[:gamelog_id].blank?

        @videoclips = @sport.videoclips.where(team_id: @team.id).and(players: params[:athlete_id]).and(gameschedule_id: params[:gameschedule_id]).
                  desc(:updated_at).paginate(per_page: 10, :page=>params[:page])

      elsif !params[:athlete_id].blank? and !params[:gameschedule_id].blank?
        
        @videoclips = @sport.videoclips.where(team_id: @team.id).and(players: params[:athlete_id]).and(gameschedule_id: params[:gameschedule_id]).
                  desc(:updated_at).paginate(per_page: 10, :page=>params[:page])

      elsif !params[:gameschedule_id].blank? and !params[:gamelog_id].blank?
        
        @videoclips = @sport.videoclips.where(team_id: @team.id).and(gameschedule_id: params[:gameschedule_id]).and(gamelog_id: params[:gamelog_id]).
                  desc(:updated_at).paginate(per_page: 10, :page=>params[:page])

      elsif !params[:athlete_id].blank?
        
        @videoclips = @sport.videoclips.where(team_id: @team.id, players: params[:athlete_id]).desc(:updated_at).paginate(per_page: 10, :page=>params[:page])

      elsif !params[:gameschedule_id].blank?
        
        @videoclips = @sport.videoclips.where(team_id: @team.id).and(gameschedule_id: params[:gameschedule_id]).desc(:updated_at).paginate(per_page: 10, :page=>params[:page])

      elsif params[:all].to_i == 0 and !params[:updated_at].nil? or !params[:updated_at].blank?
        @videoclips = @sport.videoclips.where(:updated_at.lt => params[:updated_at].any_of({athlete_id: params[:athlete_id]}, 
                              {coach_id: params[:coach_id]}, {user_id: params[:user_id]}, {gameschedule: params[:gameschedule_id]}, 
                              {gamelog: params[:gamelog_id]}).to_s.to_datetime).limit(20).desc(:updated_at)
      else
        @videoclips = @sport.videoclips.where(team_id: @team.id).desc(:updated_at).paginate(per_page: 20, page: params[:page])
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
    team = @sport.teams.find(params[:teamid])
    @gameschedules = team.gameschedules
    @athletes = @sport.athletes.where(team_id: team.id.to_s)
    if !params[:gameschedule_id].nil? and !params[:gameschedule_id].blank?
      @gamelogs = Gameschedule.find(params[:gameschedule_id]).gamelogs
    else
      @gamelogs = []
    end
#    render 'videoclips/updategameschedule'    
  end
  
  def updategamelogs
    @gamelogs = Gameschedule.find(params[:gameid].to_s).gamelogs
  end
  
  def edit
    @athletes = []
    if @videoclip.team_id.nil?
      ath = @sport.athletes
    else
      ath = @sport.athletes.where(team: @videoclip.team_id)
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
    if @videoclip.gameschedule
      @gamelogs = Gameschedule.find(@videoclip.gameschedule_id.to_s).gamelogs
    else
      @gamelogs = []
    end
  end
  
  def update
    begin
      @videoclip.update_attributes!(params[:videoclip])

      s3 = AWS::S3.new
      bucket = s3.buckets[S3DirectUpload.config.bucket]
      obj = bucket.objects[@videoclip.filepath]
      @videoclip.video_url = obj.url_for(:read, expires:  473040000)
      posterobj = bucket.objects[@videoclip.poster_filepath]
      @videoclip.poster_url = posterobj.url_for(:read, expires:  473040000)

      puts @videoclip.poster_url
      puts @videoclip.video_url

      if @videoclip.players.nil?
        @videoclip.players = Array.new
      end

      if !params[:athlete].nil? and !params[:athlete][:id].blank?
        unless @videoclip.players.include?(params[:athlete][:id].to_s)
          @videoclip.players << params[:athlete][:id].to_s
        end
      end

      @videoclip.save!
   
      respond_to do |format|
        format.html { redirect_to [@sport, @videoclip], notice: "Update successful!" }
        format.json { render json: { videoclip: @videoclip, request: [@sport, @videoclip] } }
        format.js
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to [@sport, @videoclip], alert: "Update failed! " + e.message }
        format.json { render status: 404, json: { error: e.message, request: [@sport, @videoclip] } }
      end
    end
  end

  def destroy
 	  begin
#      @sport.mediasize = @sport.mediasize - @videoclip.size
      @sport.save
	  	@videoclip.destroy
      respond_to do |format|
	  	  format.html { redirect_to sport_videoclips_path(@sport), notice: "Videoclip delete sucessful!" }
        format.json { render json: { sucess: "successful" } }
      end
    rescue Exception => e
      respond_to do |format|
	  	  format.html { redirect_to :back, alert: "Error deleting video " + e.message }
        format.json { render status: 404, json: { error: e.message, videoclip: @videoclip } }
      end
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

   def untag_athletes
    begin
      params[:videoclip].each do |key, values|
        @videoclip.players.delete(values.to_s)
      end
      @videoclip.save!

      respond_to do |format|
        format.json { render json: { videoclip: @videoclip, request: [@sport, @videoclip] } }
      end
    rescue Exception => e
      respond_to do |format|
        format.json {  render status: 404, json: { error: e.message, request: [@sport, @videoclip] } }
      end
    end
  end

  def tag_athletes
    begin
      params[:videoclip].each do |key, values|
        if @videoclip.players.nil?
          @videoclip.players = Array.new
        end
        unless @videoclip.players.include?(values.to_s)
          @videoclip.players << values.to_s
        end
        @videoclip.save!
      end
      respond_to do |format|
        format.json { render json: { videoclip: @videoclip } }
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render status: 404, json: { error: e.message } }
      end
    end
  end
  
  private

  	def get_sport
      puts params[:sport_id]
  		@sport = Sport.find(params[:sport_id])
      puts @sport.id
  	end

  	def correct_video
  		@videoclip = Videoclip.find(params[:id])
  	end

    def createNewsItem(video)
      newsitem = @sport.newsfeeds.new(videoclip_id: video.id, news: video.description, title: video.displayname, team_id: video.team_id,
                                      gameschedule_id: video.gameschedule_id)

      if video.description.nil? or video.description.blank?
        newsitem.news = "New highlight posted - " + video.displayname
      end

      newsitem.save!
    end
  
end

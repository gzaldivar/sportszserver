class BlogsController < ApplicationController
    before_filter :authenticate_user!,  only: [:new, :create, :edit, :update, :destroy]
  	before_filter :get_sport
  	before_filter :get_blog,			      only: [:edit, :update, :show, :destroy, :comment]
    before_filter :blog_owner?,         only: [:edit, :update, :destroy]
    before_filter do |controller|
      packageEnabled?(current_site)
    end

  	def new
  		@blog = Blog.new()
      @teams = @sport.teams
      @athletes = @sport.athletes
      @coaches = @sport.coaches
      @gameschedules = []
  	end

    def newteamblog
      @blog = Blog.new()
      @team = @sport.teams.find(params[:team_id])
      @athletes = @sport.athletes.where(team_id: @team.id.to_s).asc(:number)
      @coaches = @sport.coaches.where(team_id: @team.id.to_s)
      @gameschedules = @team.gameschedules
      @gamelogs = []
      render 'new'
    end

    def comment
      select_teams(@blog)
      @oldblog = @blog
      @blog = @sport.blogs.new(user: @oldblog.user, gameschedule: @oldblog.gameschedule, athlete: @oldblog.athlete, 
                               team: @oldblog.team, coach: @oldblog.coach, gamelog: @oldblog.gamelog)
      if !@oldblog.title.include?('RE:')
        @oldblog.title = "RE: " + @oldblog.title
      end
#      render 'edit'
    end

  	def create
      begin 
        blog = @sport.blogs.create!(params[:blog])

        respond_to do |format|
          format.html { redirect_to sport_blogs_path(@sport, team_id: current_team.id), notice: "Added #{blog.title}!" }
          format.json { render json: { blog: blog, avatar: User.find(blog.user).avatarthumburl, tinyavatar: User.find(blog.user).avatartinyurl } }
        end
        
      rescue Exception => e
        puts e.message
        respond_to do |format|
          format.html { redirect_to :back, alert: "Error adding Blog " + e.message } 
          format.json { render status: 404, json: { error: e.message, request: sport_blogs_url(@sport) } }
        end
      end
  	end

  	def edit
      @teams = @sport.teams
      if !@blog.team_id.nil?
          @team = @sport.teams.find(@blog.team_id.to_s)
          @athletes = @sport.athletes.where(team: @blog.team_id).asc(:number)
          @coaches = @sport.coaches.where(team: @blog.team_id)
          @gameschedules = @sport.teams.find(@blog.team_id).gameschedules
          if @blog.gameschedule_id.nil?
            @gamelogs = []
          else
            @gamelogs = @team.gameschedules.find(@blog.gameschedule_id.to_s).gamelogs
          end
      else
          @athletes = @sport.athletes
          @coaches = @sport.coaches
      end
  	end

  	def index

      if params[:team_id]
        @team = @sport.teams.find(params[:team_id])
      end

      if params[:all].to_i == 1 
        @blogs = @sport.blogs.where(team_id: @team.id).desc(:updated_at).paginate(per_page: 40, page: params[:page])
      elsif !params[:athlete_id].blank? and !params[:coach_id].blank? and !params[:gameschedule_id].blank? and !params[:gamelog_id].blank?

        @blogs = @sport.blogs.where(team_id: @team.id).and(athlete_id: params[:athlete_id]).and(coach_id: params[:coach_id]).
                    and(gameschedule_id: params[:gameschedule_id]).and(gamelog_id: params[:gamelog_id]).desc(:updated_at).
                    paginate(per_page: 40, :page=>params[:page])

      elsif !params[:athlete_id].blank? and !params[:coach_id].blank? and !params[:gameschedule_id].blank?

        @blogs = @sport.blogs.where(team_id: @team.id).and(athlete_id: params[:athlete_id]).and(coach_id: params[:coach_id]).
                    and(gameschedule_id: params[:gameschedule_id]).desc(:updated_at).paginate(per_page: 40, :page=>params[:page])

      elsif !params[:athlete_id].blank? and !params[:gameschedule_id].blank? and !params[:gamelog_id].blank?

        @blogs = @sport.blogs.where(team_id: @team.id).and(athlete_id: params[:athlete_id]).and(gameschedule_id: params[:gameschedule_id]).
                  desc(:updated_at).paginate(per_page: 40, :page=>params[:page])

      elsif !params[:coach_id].blank? and !params[:gameschedule_id].blank? and !params[:gamelog_id].blank?
        
        @blogs = @sport.blogs.where(team_id: @team.id).and(coach_id: params[:coach_id]).and(gameschedule_id: params[:gameschedule_id]).
                  desc(:updated_at).paginate(per_page: 40, :page=>params[:page])

      elsif !params[:athlete_id].blank? and !params[:gameschedule_id].blank?
        
        @blogs = @sport.blogs.where(team_id: @team.id).and(athlete_id: params[:athlete_id]).and(gameschedule_id: params[:gameschedule_id]).
                  desc(:updated_at).paginate(per_page: 40, :page=>params[:page])

      elsif !params[:coach_id].blank? and !params[:gameschedule_id].blank?
        
        @blogs = @sport.blogs.where(team_id: @team.id).and(coach_id: params[:coach_id]).and(gameschedule_id: params[:gameschedule_id]).
                  desc(:updated_at).paginate(per_page: 40, :page=>params[:page])

      elsif !params[:gameschedule_id].blank? and !params[:gamelog_id].blank?
        
        @blogs = @sport.blogs.where(team_id: @team.id).and(gameschedule_id: params[:gameschedule_id]).and(gamelog_id: params[:gamelog_id]).
                  desc(:updated_at).paginate(per_page: 40, :page=>params[:page])

      elsif !params[:athlete_id].blank?
        
        @blogs = @sport.blogs.where(team_id: @team.id).and(athlete_id: params[:athlete_id]).desc(:updated_at).paginate(per_page: 40, :page=>params[:page])

      elsif !params[:coach_id].blank?
        
        @blogs = @sport.blogs.where(team_id: @team.id).and(coach_id: params[:coach_id]).desc(:updated_at).paginate(per_page: 40, :page=>params[:page])

      elsif !params[:gameschedule_id].blank?
        
        @blogs = @sport.blogs.where(team_id: @team.id).and(gameschedule_id: params[:gameschedule_id]).desc(:updated_at).paginate(per_page: 40, :page=>params[:page])

      elsif params[:all].to_i == 0 and !params[:updated_at].nil? or !params[:updated_at].blank?
        @blogs = @sport.blogs.where(:updated_at.lt => params[:updated_at].any_of({athlete_id: params[:athlete_id]}, 
                              {coach_id: params[:coach_id]}, {user_id: params[:user_id]}, {gameschedule: params[:gameschedule_id]}, 
                              {gamelog: params[:gamelog_id]}).to_s.to_datetime).limit(40).desc(:updated_at)
      else
        @blogs = @sport.blogs.where(team_id: @team.id).desc(:updated_at).paginate(per_page: 20, page: params[:page])
      end

      if @team.nil?
        @coaches = @sport.coaches
        @athletes = @sport.athletes
        @gameschedules = []
        @gamelogs = []
      else
        @coaches = @sport.coaches.where(team_id: @team.id.to_s)
        @athletes = @sport.athletes.where(team_id: @team.id.to_s).asc(:number)
        @gameschedules = @team.gameschedules
        @gamelogs = []
      end

      respond_to do |format|
        format.html
        format.json
      end
  	end

  	def update
      begin 
        @blog.update_attributes!(params[:blog])

        respond_to do |format|
          format.html { redirect_to sport_blogs_path(@sport, team_id: current_team.id), notice: "Updated #{@blog.title}!" }
          format.json { render json: { blog: blog, avatar: User.find(@blog.user).avatarthumburl, tinyavatar: User.find(@blog.user).avatartinyurl } }
        end
        
      rescue Exception => e
        puts e.message
        respond_to do |format|
          format.html { redirect_to :back, alert: "Error updating Blog " + e.message }
          format.json { render status: 404, json: { error: e.message, request: sport_blog_url(@sport, @blog) } }
        end
      end  		
  	end

  	def show
      @bloguser = User.find(@blog.user_id)
      respond_to do |format|
        format.html
        format.json
      end
  	end

  	def destroy
      begin
        if @blog.team_id.nil?
          @blog.destroy
          respond_to do |format|
            format.html { redirect_to sport_blogs_path(@sport), notice: "Blog delete sucessful!" }
            format.json { render json: { message: "Success", request: sport_blogs_url(@sport) } }
          end
        else
          @team = @sport.teams.find(@blog.team_id)
          @blog.destroy
          respond_to do |format|
            format.html { redirect_to sport_blogs_path(@sport, team_id: @team.id), notice: "Blog deleted for " + @team.team_name }
            format.json { render json: { message: "Success", request: sport_blogs_path(@sport, team_id: @team.id) } }
          end
        end
      rescue Exception => e
        respond_to do |format|
          format.html { redirect_to sport_blogs_path(@sport), alert: "Error deleting blog entry" }
          format.json { render status: 404, json: { error: e.message, request: sport_blogs_url(@sport) } }
        end
      end
  	end

    def updateforteams
      @gameschedules = @sport.teams.find(params[:teamid]).gameschedules
      @athletes = @sport.athletes.where(team: params[:teamid].to_s).entries
      @coaches = @sport.coaches.where(team: params[:teamid].to_s).entries
    end

    def updategamelogs
      @gamelogs = Gameschedule.find(params[:gameid].to_s).gamelogs
    end
  
  	private

  		def get_sport
  			@sport = Sport.find(params[:sport_id])
  		end

  		def get_blog
  			@blog = @sport.blogs.find(params[:id])
  		end

      def select_teams(blog)
        @teams = @sport.teams
        if !blog.team_id.nil?
            @athletes = @sport.athletes.where(team_id: blog.team_id).entries
            @coaches = @sport.coaches.where(team_id: blog.team_id).entries
            @gameschedules = @sport.teams.find(blog.team_id).gameschedules
        else
            @athletes = @sport.athletes
            @coaches = @sport.coaches
            @gameschedules = []
        end
      end

      def blog_owner?
        (current_user.id == @blog.user_id) or site_owner? 
      end
end

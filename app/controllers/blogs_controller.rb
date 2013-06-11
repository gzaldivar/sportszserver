class BlogsController < ApplicationController
    before_filter :authenticate_user!,  only: [:new, :create, :edit, :update, :destroy]
  	before_filter :get_sport
  	before_filter :get_blog,			      only: [:edit, :update, :show, :destroy, :comment]
    before_filter :blog_owner?,         only: [:edit, :update, :destroy]

  	def new
  		@blog = Blog.new()
      @teams = @sport.teams
      @athletes = @sport.athletes
      @coaches = @sport.coaches
      @gameschedules = []
  	end

    def comment
      select_teams(@blog)
      @oldblog = @blog
      @blog = @sport.blogs.new(user: @oldblog.user, gameschedule: @oldblog.gameschedule, athlete: @oldblog.athlete, 
                               team: @oldblog.team, coach: @oldblog.coach)
      if !@oldblog.title.include?('RE:')
        @oldblog.title = "RE: " + @oldblog.title
      end
#      render 'edit'
    end

  	def create
      begin 
        blog = @sport.blogs.create!(params[:blog])

        respond_to do |format|
          format.html { redirect_to [@sport, blog], notice: "Added #{blog.title}!" }
          format.json { render json: { blog: blog, request: sport_blog_url(@sport, blog) } }
        end
        
      rescue Exception => e
        respond_to do |format|
          format.html { redirect_to :back, alert: "Error adding Blog " + e.message } 
          format.json { render status: 404, json: { error: e.message, request: sport_blogs_url(@sport) } }
        end
      end
  	end

  	def edit
      @teams = @sport.teams
      if !@blog.team_id.nil?
          @athletes = @sport.athletes.where(team: @blog.team_id).entries
          @coaches = @sport.coaches.where(team: @blog.team_id).entries
          @gameschedules = @sport.teams.find(@blog.team_id).gameschedules
      else
          @athletes = @sport.athletes
          @coaches = @sport.coaches
      end
  	end

  	def index
      if !params[:team_id].nil? and !params[:team_id].blank? and !params[:updated_at].nil? and !params[:updated_at].blank?
        @blogs = @sport.blogs.where(team_id: params[:team_id].to_s, :updated_at.gt => params[:updated_at.to_date]).limit(20).desc(:updated_at)
      elsif !params[:team_id].nil? and !params[:team_id].blank?
        @blogs = @sport.blogs.where(team: params[:team_id].to_s).limit(20).desc(:updated_at).entries
      elsif !params[:athlete].nil? and !params[:athlete][:id].blank? and !params[:updated_at].nil? and !params[:updated_at].blank?
        @blogs = @sport.blogs.where(athlete: params[:athlete][:id].to_s, :updated_at.gt => params[:updated_at.to_date]).limit(20).desc(:updated_at)        
      elsif !params[:athlete].nil? and !params[:athlete][:id].blank?
        @blogs = @sport.blogs.where(athlete: params[:athlete][:id].to_s).limit(20).desc(:updated_at)
      elsif !params[:coach].nil? and !params[:coach][:id].blank? and !params[:updated_at].nil? and !params[:updated_at].blank?
        @blogs = @sport.blogs.where(coach: params[:coach][:id].to_s, :updated_at.gt => params[:updated_at.to_date]).limit(20).desc(:updated_at)
      elsif !params[:coach].nil? and !params[:coach][:id].blank?
        @blogs = @sport.blogs.where(coach: params[:coach][:id].to_s).limit(20).desc(:updated_at)
      elsif !params[:player].nil? and !params[:player].blank?
        @blogs = @sport.blogs.where(athlete: params[:player].to_s).limit(20).desc(:updated_at)
      elsif !params[:teamname].nil? and !params[:teamname].blank?
        @blogs = @sport.blogs.where(team: params[:teamname].to_s).limit(20).desc(:updated_at)
      elsif !params[:coachname].nil? and !params[:coachname].blank?
        @blogs = @sport.blogs.where(coach: params[:coachname].to_s).limit(20).desc(:updated_at)      
      elsif !params[:gamename].nil? and !params[:gamename].blank?
        @blogs = @sport.blogs.where(gameschedule: params[:gamename].to_s).limit(20).desc(:updated_at)      
      else
        @blogs = @sport.blogs.limit(40).desc(:updated_at)
      end
      
      @coaches = @sport.coaches
      @athletes = @sport.athletes

      if !params[:team_id].nil? and !params[:team_id].blank?
        @gameschedules = @sport.teams.find(params[:team_id].to_s).gameschedules
      else
        @gameschedules = nil
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
          format.html { redirect_to [@sport, @blog], notice: "Updated #{@blog.title}!" }
          format.json { render json: { blog: blog, request: sport_blog_url(@sport, blog) } }
        end
        
      rescue Exception => e
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
        if @blog.team.nil?
          @blog.destroy
          respond_to do |format|
            format.html { redirect_to sport_blogs_path(@sport), notice: "Blog delete sucessful!" }
            format.json { render json: { message: "Success", request: sport_blogs_url(@sport) } }
          end
        else
          @team = @sport.teams.find(@blog.team)
          @blog.destroy
          respond_to do |format|
            format.html { redirect_to sport_blogs_path(@sport, team_id: @team), notice: "Blog deleted for " + @team.team_name }
            format.json { render json: { message: "Success", request: sport_blogs_path(@sport, team_id: @team) } }
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

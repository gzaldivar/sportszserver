class BlogsController < ApplicationController
    before_filter :authenticate_user!,  only: [:new, :create, :edit, :update, :destroy]
    before_filter :site_owner?,			    only: [:destroy]
  	before_filter :get_sport
  	before_filter :get_blog,			      only: [:edit, :update, :show, :destroy, :comment]

  	def new
  		@blog = Blog.new
      @teams = @sport.teams
      @athletes = @sport.athletes
      @coaches = @sport.coaches
      @gameschedules = []
  	end

    def comment
      select_teams(@blog)
      @oldblog = @blog
      @blog = Blog.new
    end

  	def create
      begin 
        blog = @sport.blogs.create!(params[:blog])
        redirect_to [@sport, blog], notice: "Added #{blog.title}!"
      rescue Exception => e
        redirect_to :back, alert: "Error adding Blog " + e.message
      end
  	end

  	def edit
      @teams = @sport.teams
      if !@blog.team.nil?
          @athletes = @sport.athletes.where(team: @blog.team).entries
          @coaches = @sport.coaches.where(team: @blog.team).entries
          @gameschedules = @sport.teams.find(@blog.team).gameschedules
      else
          @athletes = @sport.athletes
          @coaches = @sport.coaches
          @gameschedules = []
      end
  	end

  	def index
      if !params[:team_id].nil? and !params[:team_id].blank?
        @blogs = @sport.blogs.where(team: params[:team_id].to_s).limit(20).desc(:updated_at).entries
      elsif !params[:athlete].nil? and !params[:athlete][:id].blank?
        @blogs = @sport.blogs.where(athlete: params[:athlete][:id].to_s).limit(20).desc(:updated_at)
      elsif !params[:coach].nil? and !params[:coach][:id].blank?
        @blogs = @sport.blogs.where(coach: params[:coach][:id].to_s).limit(20).desc(:updated_at)
      elsif !params[:player].nil? and !params[:player].blank?
        @blogs = @sport.blogs.where(athlete: params[:player].to_s).limit(20).desc(:updated_at)
      elsif !params[:teamname].nil? and !params[:teamname].blank?
        @blogs = @sport.blogs.where(team: params[:teamname].to_s).limit(20).desc(:updated_at)
      elsif !params[:coachname].nil? and !params[:coachname].blank?
        @blogs = @sport.blogs.where(coach: params[:coachname].to_s).limit(20).desc(:updated_at)      
      else
        @blogs = @sport.blogs.limit(40).desc(:updated_at)
      end
      
      @coaches = @sport.coaches
      @athletes = @sport.athletes

      respond_to do |format|
        format.html
        format.json
      end
  	end

  	def update
      begin 
        @blog.update_attributes!(params[:blog])
        redirect_to [@sport, @blog], notice: "Updated #{@blog.title}!"
      rescue Exception => e
        redirect_to :back, alert: "Error adding Blog " + e.message
      end  		
  	end

  	def show  		
  	end

  	def destroy
      if @blog.team.nil?
        @blog.destroy
        redirect_to sport_blogs_path(@sport), notice: "Blog delete sucessful!"
      else
        @team = @sport.teams.find(@blog.team)
        @blog.destroy
        redirect_to sport_blogs_path(@sport, team_id: @team), notice: "Blog deleted for " + @team.team_name
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
end

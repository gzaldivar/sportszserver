class AdminsController < ApplicationController
	before_filter :authenticate_user!,	only: [:update, :edit, :index, :sports, :users, :admonitoring]
	before_filter :isGod?
	before_filter :getAdmin, only: [:edit, :update, :index]

	def edit
	end

	def update
		@admin.update_attributes!(params[:admin])
		redirect_to admins_path
	end

	def index
		@admin = Admin.first
		render 'show'
	end

	def admonitoring
		@sponsors = Sponsor.where(sharepaid: false).paginate(:page => params[:page])
	end

	def sports
		@sports = Sport.all.desc(:updated_at).paginate(:page => params[:page])
	end

	def users
    	@users = User.all.desc(:updated_at).paginate(page: params[:page])
	end

	def deleteuser
		begin
			@user = User.find(params[:user_id])

			if !@user.admin || (@user.admin && @user.confirmed_at.nil?)
				@user.destroy
				@user.photos = nil
				@user.videoclips = nil
				@user.events = nil

				redirect_to users_admins_path, notice: "User deleted"
			else
				raise "Cannot delete administrator of a site."
			end
		rescue Exception => e
			redirect_to :back, alert: e.message
		end
	end

	def email
		
	end

	def sendemail
		@users = []

		if params[:sportname]
			if params[:admin].to_i == 1
				Sport.where(name: params[:sportname]).each_with_index do |s, cnt|
					@users[cnt] = User.find(s.adminid)
				end
			else
				Sport.where(name: params[:sportname]).each_with_index do |s, cnt|
					sportusers = User.where(default_site: s.id.to_s)
					(@users << sportusers).flatten
				end
			end
		elsif params[:nosite].to_i == 1
			User.where(admin: true, :confirmed_at.exists => true).each do |u|
				if !Sport.find_by(adminid: u.id.to_s)
					@users << u
				end
			end
		elsif params[:admin].to_i == 1
			@users = User.where(admin: true)
		elsif params[:unconfirmed]
			@users = User.where(:confirmed_at.exists => false)
		elsif params[:useremail]
			@users = User.where(email: params[:useremail])
		else
			@users = User.all
		end

		UserMailer.gametracker_news(@users, params[:paragraphone], params[:paragraphtwo], params[:paragraphthree]).deliver
	end

	private

		def getAdmin
			@admin = Admin.all.first
		end

end
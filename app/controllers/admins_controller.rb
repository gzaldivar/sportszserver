class AdminsController < ApplicationController
	before_filter :authenticate_user!,	only: [:update, :edit, :index, :sports, :users]
	before_filter :isGod?
	before_filter :getAdmin, only: [:edit, :update, :index]

	def edit
	end

	def update
		@admin.update_attributes!(params[:admin])
		redirect_to admins_path
	end

	def index
		render 'show'
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

	private

		def isGod?
			current_user.godmode
		end

		def getAdmin
			@admin = Admin.all.first
		end

end
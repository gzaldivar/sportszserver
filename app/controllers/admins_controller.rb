class AdminsController < ApplicationController

	def show
	end

	def index
		@sports = Sport.all.paginate(:page => params[:page])
	end

	def users
    	@users = User.all.paginate(page: params[:page])
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


end
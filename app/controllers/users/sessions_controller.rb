class Users::SessionsController < Devise::SessionsController

	def create
		respond_to do |format|
			format.html {
				super
			}
			format.json {
			    resource = warden.authenticate!(:scope => resource_name, :recall => "users/sessions#failure")
			    user = User.new
			    user = resource
			    sign_in(resource_name, resource)
			    user.reset_authentication_token
			    user.save!
			 	render :json => { :success => true, :user => user, authentication_token: user.authentication_token }, :status => 200
			}
		end
	end

	def failure
	    return render :status => 401, :json => {:success => false, :errors => ["Login failed."]}
	end  

end

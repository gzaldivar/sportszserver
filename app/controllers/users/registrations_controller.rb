class Users::RegistrationsController < Devise::RegistrationsController
  
  def create
    respond_to do |format|
        format.html {
          super
          if current_site?
            resource.default_site = current_site.id   #set default site
            resource.save
          end
        }
        format.json {
          if params[:user][:email].nil?
            render :status => 400,
                   :json => {:message => 'User request must contain the user email.'}
            return
          elsif params[:user][:password].nil?
            render :status => 400,
                   :json => {:message => 'User request must contain the user password.'}
            return
          elsif params[:user][:name].nil?
            render :status => 400,
                   :json => {:message => 'User request must contain the user name.'}
          end
          if params[:user][:site].nil?
            render status: 400, json: {message: "Site is missing"}
            return
          end
          if !Sport.find(params[:user][:site].to_s)
            render status: 400, json: {message: "Site does not exist"}
            return
          end

          if params[:user][:email]
            duplicate_user = User.find_by(email: params[:user][:email])
            unless duplicate_user.nil?
              render :status => 409,
                     :json => {:message => 'Duplicate email. A user already exists with that email address.'}
              return
            end
          end

          @user = User.create(params[:user])
          @user.default_site = params[:user][:site]

          if @user.save
            render :status => 200, :json => {:user => @user}
          else
            render :status => 400,
                   :json => {:message => @user.errors.full_messages}
          end
        }
    end
  end

  def update
    respond_to do |format|
      format.html {
        super
      }
      format.json {
        user = User.find(authentication_token: params[:user][:auth_token])

        prev_unconfirmed_email = user.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

        if user.update_with_password(params[:user])
          if is_navigational_format?
            flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
              :update_needs_confirmation : :updated
              render status: 400, json: { message: "Confirm account via email" }
          end
          sign_in resource_name, resource, :bypass => true
          user = User.new
          user = resource
          render status: 200, json: { user: user, authentication_token: user.authentication_token }
        else
          clean_up_passwords resource
          render status: 200, json: { user: resouce }
        end
      }
    end
  end

end
class Users::RegistrationsController < Devise::RegistrationsController

  def create
    respond_to do |format|
        format.html {
#            super
            build_resource(sign_up_params)

            if current_site?
              resource.default_site = current_site.id   #set default site
            else
              resource.admin = true
            end

            if resource.save
              yield resource if block_given?
              if resource.active_for_authentication?
                set_flash_message :notice, :signed_up if is_flashing_format?
                sign_up(resource_name, resource)
                respond_with resource, :location => after_sign_up_path_for(resource)
              else
                set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
                expire_data_after_sign_in!
                respond_with resource, :location => after_inactive_sign_up_path_for(resource)
              end
            else
              clean_up_passwords resource
              respond_with resource
            end

#              resource.save
        }
        format.json {
          begin
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
            if params[:user][:admin].nil? and params[:user][:site].nil?
              render status: 400, json: {message: "Site is missing"}
              return
            end
            if params[:user][:admin].nil? and !Sport.find(params[:user][:site].to_s)
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

            if params[:user][:mobile]
              @user.mobile = params[:user][:mobile]
            end

            if !params[:user][:site].nil? and Sport.find(params[:user][:site].to_s).beta?
              @user.tier = "Features"
            end

            if params[:user][:admin]
              @user.admin = true
            end

            if @user.save!
              render :status => 200, :json => {:user => @user}
            else
              render :status => 400, :json => {:message => @user.errors.full_messages}
            end
          rescue Exception => e
            puts "Exception raised " + e.message
            render status: 404, json: { error: e.message }
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
        begin
          @user = User.find_by(authentication_token: params[:auth_token])

          successfully_updated = if needs_password?(@user, params)
            @user.update_with_password(params[:user])
          else
            # remove the virtual current_password attribute update_without_password
            # doesn't know how to ignore it
            params[:user].delete(:current_password)
            @user.update_without_password(params[:user])
          end

  #        if successfully_updated
  #          set_flash_message :notice, :updated
            # Sign in the user bypassing validation in case his password changed
  #          sign_in @user, :bypass => true
  #          redirect_to after_update_path_for(@user)
            render status: 200, json: { user: @user, authentication_token: @user.authentication_token }
  #        else
        rescue Exception => e
            render status: 404, json: { error: "Error updating user " + e.message }
        end
      }
    end
  end

  private

    # check if we need password to update user data
    # ie if password or email was changed
    # extend this as needed
    def needs_password?(user, params)
      user.email != params[:user][:email] ||
        !params[:user][:password].blank?
    end

    def after_inactive_sign_up_path_for(resource)
      puts 'inactive'
        if resource.default_site.nil?
          root_path
        else
          sport_path(resource.default_site)
        end
    end
   
    def after_sign_up_path_for(resource)
      puts 'after sign up'
      if resource.default_site.nil?
        root_path
      else
        sport_path(resource.default_site)
      end
    end



end
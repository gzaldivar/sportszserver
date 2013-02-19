class Users::RegistrationsController < Devise::RegistrationsController
  
  def create
    super
    if current_site?
      resource.default_site = current_site.id   #set default site
      resource.save
    end
  end
 
end
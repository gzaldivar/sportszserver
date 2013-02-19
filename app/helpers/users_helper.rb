module UsersHelper

	def site_owner?
	  if current_site?
		  return current_user == current_site.user
	  else
	    return nil
    end
	end

end

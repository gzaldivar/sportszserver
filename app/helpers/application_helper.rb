module ApplicationHelper

  # Returns the full title on a per-page basis.
	def full_title(page_title)
	    base_title = "Eazesportz.com"
	    if page_title.empty?
	      base_title
	    else
	      "#{base_title} | #{page_title}"
	    end
	end

	def resource_name
		:user
	end

	def resource
		@resource ||= User.new
	end

	def devise_mapping
		@devise_mapping ||= Devise.mappings[:user]
	end

	def is_package_enabled?(sport)
		if !sport.nil? and !current_user.godmode
			payment = Payment.find_by(sport_id: sport.id)

			if payment.nil?
				return false
			else
				if payment.isSilver? or payment.isGold? or isPlatinum?
					return true
			  	else
			  		return false
				end
			end
		elsif current_user.godmode
			return true
		else
			return false
		end
	end

	def packageEnabled?(sport)
		if !sport.nil? and !current_user.godmode
			payment = Payment.find_by(sport_id: sport.id)

			if payment.nil?
				raise ActionController::RoutingError.new('Eazesportz upgrade needed for this functionality. You can upgrade from the Tools menu!')
			else
				if payment.isSilver? or payment.isGold? or isPlatinum?
					return true
			  	else
			      	raise ActionController::RoutingError.new('Eazesportz upgrade needed for this functionality. You can upgrade from the Tools menu!')
				end
			end
		elsif current_user.godmode
			return true
		else
			return false
		end
	end

	def roomformedia?(sport)
		if !sport.nil? and !current_user.godmode
			payment = Payment.find_by(sport_id: sport.id)

			if payment.nil?
				raise ActionController::RoutingError.new('Eazesportz upgrade needed for this functionality. You can upgrade from the Tools menu!')
			elsif payment.isSilver? and sport.mediasize > 300000000
			 	return false
			elsif payment.isGold? and sport.mediasize > 1000000000
			 	return false
			elsif payment.isPlatinum?
			 	return true
			else
			 	return true
			end
		elsif current_user.godmode
			return true
		else
			return false
		end
	end
 
	def sponsorEnabled?(sport)
		if !sport.nil? and !current_user.godmode
			payment = Payment.find_by(sport_id: sport.id)

			if payment.nil?
				raise ActionController::RoutingError.new('Eazesportz upgrade needed for this functionality. You can upgrade from the Tools menu!')
			else
				if payment.isGold? or isPlatinum?
					return true
			  	else
			      	raise ActionController::RoutingError.new('Eazesportz upgrade needed for this functionality. You can upgrade from the Tools menu!')
				end
			end
		elsif current_user.godmode
			return true
		else
			return false
		end
	end

	def isSilver?(sport)
		if !sport.nil?
			payment = Payment.find_by(sport_id: sport.id)

			if payment.nil?
				raise ActionController::RoutingError.new('Eazesportz upgrade needed for this functionality. You can upgrade from the Tools menu!')
			else
				if !payment.isSilver?
			      raise ActionController::RoutingError.new('Eazesportz upgrade needed for this functionality. You can upgrade from the Tools menu!')
				end
			end
		end
	end

	def is_silver?
		if !current_site.nil?
			payment = Payment.find_by(sport_id: current_site.id)

			if payment.nil?
				false
			else
				payment.isSilver?
			end
		end
	end

	def isGold?
		if !current_site.nil?
			payment = Payment.find_by(sport_id: current_site.id)

			if payment.nil?
				raise ActionController::RoutingError.new('Eazesportz upgrade needed for this functionality. You can upgrade from the Tools menu!')
			else
				if !payment.isGold?
					raise ActionController::RoutingError.new('Eazesportz upgrade needed for this functionality. You can upgrade from the Tools menu!')
				end
			end
		end
	end

	def is_gold?
		if !current_site.nil?
			payment = Payment.find_by(sport_id: current_site.id)

			if payment.nil?
				false
			else
				payment.isGold?
			end
		end
	end

	def isPlatinum?
		if !current_site.nil?
			payment = Payment.find_by(sport_id: current_site.id)

			if payment.nil?
				raise ActionController::RoutingError.new('Eazesportz upgrade needed for this functionality. You can upgrade from the Tools menu!')
			else
				if !payment.isPlatinum?
					raise ActionController::RoutingError.new('Eazesportz upgrade needed for this functionality. You can upgrade from the Tools menu!')
				end
			end
		end
	end

	def is_platinum?
		if !current_site.nil?
			payment = Payment.find_by(sport_id: current_site.id)

			if payment.nil?
				false
			else
				payment.isPlatinum?
			end
		end
	end

end


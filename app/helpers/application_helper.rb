module ApplicationHelper

  # Returns the full title on a per-page basis.
	def full_title(page_title)
	    base_title = "GameTrackerPro.com"
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
		if user_signed_in? and current_user.godmode
			return true
		elsif !sport.nil?
			payment = Payment.find_by(sport_id: sport.id)

			if payment.nil?
				return false
			else
				if payment.isSilver? or payment.isGold? or payment.isPlatinum?
					return true
			  	else
			  		return false
				end
			end
		else
			return false
		end
	end

	def packageEnabled?(sport)
		if user_signed_in? and current_user.godmode
			return true
		elsif !sport.nil?
			payment = Payment.find_by(sport_id: sport.id)

			if payment.nil?
				raise ActionController::RoutingError.new('Game Tracker upgrade needed for this functionality. You can upgrade from the Tools menu!')
			else
				if payment.isSilver? or payment.isGold? or payment.isPlatinum?
					return true
			  	else
			      	raise ActionController::RoutingError.new('Game Tracker upgrade needed for this functionality. You can upgrade from the Tools menu!')
				end
			end
		else
			return false
		end
	end

	def roomformedia?(sport)
		if !sport.nil? and user_signed_in? and !current_user.godmode
			payment = Payment.find_by(sport_id: sport.id)

			if payment.nil? and sport.mediasize < sport.silverMedia
				return true
#				raise ActionController::RoutingError.new('Game Tracker upgrade needed for this functionality. You can upgrade from the Tools menu!')
			elsif !payment.nil? and payment.isSilver? and sport.mediasize > sport.silverMedia
			 	return false
			elsif !payment.nil? and payment.isGold? and sport.mediasize > sport.goldMedia
			 	return false
			elsif !payment.nil? and payment.isPlatinum? and sport.mediasize > sport.platinumMedia
			 	return true
			else
			 	return false
			end
		elsif user_signed_in? and current_user.godmode
			return true
		else
			return false
		end
	end
 
	def sponsorEnabled?(sport)
		if !sport.nil? and user_signed_in? and !current_user.godmode
			payment = Payment.find_by(sport_id: sport.id)

			if payment.nil?
				raise ActionController::RoutingError.new('Game Tracker upgrade needed for this functionality. You can upgrade from the Tools menu!')
			else
				if payment.isGold? or payment.isPlatinum?
					return true
			  	else
			      	raise ActionController::RoutingError.new('Game Tracker upgrade needed for this functionality. You can upgrade from the Tools menu!')
				end
			end
		elsif user_signed_in? and current_user.godmode
			return true
		else
			return false
		end
	end

	def isSilver?(sport)
		if !sport.nil?
			payment = Payment.find_by(sport_id: sport.id)

			if payment.nil?
				raise ActionController::RoutingError.new('Game Tracker upgrade needed for this functionality. You can upgrade from the Tools menu!')
			else
				if !payment.isSilver?
			      raise ActionController::RoutingError.new('Game Tracker upgrade needed for this functionality. You can upgrade from the Tools menu!')
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
				raise ActionController::RoutingError.new('Game Tracker upgrade needed for this functionality. You can upgrade from the Tools menu!')
			else
				if !payment.isGold?
					raise ActionController::RoutingError.new('Game Tracker upgrade needed for this functionality. You can upgrade from the Tools menu!')
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
				raise ActionController::RoutingError.new('Game Tracker upgrade needed for this functionality. You can upgrade from the Tools menu!')
			else
				if !payment.isPlatinum?
					raise ActionController::RoutingError.new('Game Tracker upgrade needed for this functionality. You can upgrade from the Tools menu!')
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


module SponsorsHelper

	def sponsorad(sport, level)
		sport.sponsors.where(sponsorlevel: level).sample
	end
end

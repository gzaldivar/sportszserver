module SponsorsHelper

	def sponsorad(sport)
		sport.sponsors.all.sample
	end
end

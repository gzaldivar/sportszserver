module SponsorsHelper

	def sponsorad(sport, level)
		sport.sponsors.where(sponsorlevel: level).sample
	end

	def getsponsor(sport)

		if sport.sponsors.count > 0
#			getnextad(sport, 0)
			sport.sponsors.where(adminentered: true).sample
		end
	end

	def number_of_adlevels(sport)
		num = 0

		sport.sportadinvs.where(playerad: false).each do |s|
			if sport.sponsors.where(sportadinv_id: s.id).count > 0
				num += 1
			end
		end

		return num
	end

	def get_adinventory_levels(sport)
		pricearray = Array.new

		sport.sportadinvs.where(playerad: false).each do |s|
			if sport.sponsors.where(sportadinv_id: s.id).count > 0
				pricearray << s
			end
		end

		return pricearray
	end

	def getnextad(sport, index, nextad)
		if index == nextad.adindex
			getnextad(sport, index + 1)
		elsif nextad.levelarray[index] < index + 1
			nextad.adindex = index
			nextad.levelarray[index] += 1
		elsif nextad.adindex == nextad.levelarray.count - 1 and nextad.levelarray[nextad.levelarray.count - 1] == nextad.levelarray.count
			for i in nextad.levelarray do
				nextad.levelarray[i] = 0
			end
			nextad.adindex = nextad.levelarray.count - 1
		end 
 	end
end

module SponsorsHelper

	def sponsorad(sport)
		sport.sponsors.where(adminenterd: true).sample
	end

	def getsponsor(sport)
		if sport.sponsors.count > 0
			levelsarray = []
			oldprice = 100000000.0
			inventory = sport.sportadinvs.where(playerad: false).desc(:price)
			cnt = inventory.count

			inventory.each_with_index do |inv, i|
				if oldprice > inv.price
					puts i
					levelsarray[i] = 2**cnt
					cnt -= 1
				end

				oldprice = inv.price
			end

	        numbers = levelsarray.count**2
	        randomNumber = rand(numbers) + Float(rand(numbers + 1) / numbers)
	        n = 0
	        totalPercentage = 0.0

	        levelsarray.each_with_index do |l, i|
	            totalPercentage += Float(l)
	            
	            if totalPercentage >= randomNumber  
	                break;
	            end
	            
	            n += 1
			end 

			sport.sponsors.where(sportadinv_id: inventory[n].id).sample
		else
			nil
 		end
	end

	def getPlayerAd(sport, athlete)
		sport.sponsors.where(athlete_id: athlete.id).sample
	end

end

module SportsHelper
    
  def deletesport(sport)
    PhotoQueue.where(sport: sport.id).each do |p|
      p.delete
    end
    Photo.where(sport: sport.id).each do |p|
      p.deletephoto
      p.delete
    end
    PhotoError.where(sport: sport.id).each do |p|
      p.delete
    end
  end
  
end

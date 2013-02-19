module PhotosHelper
  
  def delete_athlete_photo(athlete_id)
    pics = Photo.where(athletes:  athlete_id)
    
    pics.each do |p|
      p.athletes(@athlete.id).delete
      p.save
    end    
  end
  
end

class CleanupNewsBlog
  
  require 'houston'

  @queue = :cleanup_queue
  
  def self.perform(id)

  	Sport.all.each do |s|
  		time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
    	newsdate = time.to_time.prev_year.to_date.iso8601

   		s.newsfeeds.where(:updated_at.lt => newsdate).each do |n|
   			n.destroy
   		end

   		time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
    	blogdate = time.to_time.prev_year.to_date.iso8601

   		s.blogs.where(:updated_at.lt => blogdate).each do |b|
   			b.destroy
   		end

      time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
#      alertdate = time.to_time.prev.to_date.iso8601
      alertdate = Time.now - 1.days

      s.athletes.each do |a|
        a.alerts.where(:updated_at.lt => alertdate).each do |alert|
          alert.destroy
        end
      end
    end
  end

end
class CleanupNewsBlog
  
  @queue = :cleanup_queue
  
  def self.perform(id)

  	Sport.all.each do |s|
  		time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
    	newsdate = time.to_time.prev_year.to_date.iso8601

   		s.newsfeeds.where(:updated_at.lt => newsdate).each do |n|
   			n.destroy
   		end

   		time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
    	blogdate = time.to_time.prev_month.to_date.iso8601

   		s.blogs.where(:updated_at.lt => blogdate).each do |b|
   			b.destroy
   		end

      time = DateTime.now.in_time_zone(Time.zone).beginning_of_day.iso8601
      alertdate = time.to_time.prev_week.to_date.iso8601

      s.athletes.each do |a|
        a.athletes.alerts.where(:updated_at.lt => alertdate).each do |alert|
          alert.destroy
        end
      end
  	end

  end
end
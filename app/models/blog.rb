class Blog
  include Mongoid::Document  
  include Mongoid::Timestamps
  include Mongoid::Search

  after_save :send_alert
  
  field :title, type: String
  field :entry, type: String
  field :external_url, type: String
 
  belongs_to :sport
  belongs_to :team
  belongs_to :athlete
  belongs_to :coach
  belongs_to :gameschedule
  has_one :alert
  belongs_to :user

  validates_presence_of :title
  validates_presence_of :entry

  private

    def send_alert
        if !self.athlete.nil?
            Athlete.find(self.athlete).followers.each do |user, name|
              alert = self.athlete.alerts.new(sport: sport, user: user, blog: self.id)
              alert.save
            end
        end
    end

end

class Blog
  include Mongoid::Document  
  include Mongoid::Timestamps
  include Mongoid::Search

  after_save :send_alert
  
  field :title, type: String
  field :entry, type: String
  field :external_url, type: String
 
  belongs_to :sport
  belongs_to :team, index: true
  belongs_to :athlete
  belongs_to :coach
  belongs_to :gameschedule
  has_one :alert
  belongs_to :user

  validates_presence_of :title
  validates_presence_of :entry
  validates_presence_of :team_id

  private

    def send_alert
        if !self.athlete.nil?
            Athlete.find(self.athlete).fans.each do |user|
              if User.find(user).blog_alert?
                alert = self.athlete.alerts.new(sport: sport, user: user, blog: self.id, message: "Blog entry added!")
                alert.save
              end
            end
        end
    end

end

class Blog
  include Mongoid::Document  
  include Mongoid::Timestamps

  after_save :send_alert
  
  field :title, type: String
  field :entry, type: String
  field :external_url, type: String
 
  belongs_to :sport
  belongs_to :team, index: true
  belongs_to :athlete
  belongs_to :coach
  belongs_to :gameschedule
  has_one :alert, dependent: :destroy
  belongs_to :user
  belongs_to :gamelog

  validates_presence_of :title
  validates_presence_of :entry
  validates_presence_of :team_id

  private

    def send_alert
        if !self.athlete.nil?
          self.athlete.alerts.create!(sport_id: sport_id, team_id: team_id, users: Athlete.find(self.athlete_id).fans, blog_id: self.id, message: "Blog entry added!")
        end
    end

end

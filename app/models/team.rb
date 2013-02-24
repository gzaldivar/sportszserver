class Team
  include Mongoid::Document
  include Mongoid::Timestamps

 
  field :title, type: String
  field :mascot, type: String

  validates_presence_of :title
  validates_presence_of :mascot

  embedded_in :sport
  has_many :gameschedules, dependent: :destroy
  has_many :fbpassing_totals, dependent: :destroy
   
  def team_name
    title + " " + mascot
  end

end

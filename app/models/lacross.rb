class Lacross
 	include Mongoid::Document
 	include Mongoid::Timestamps

 	field :goal, type: Integer
    field :shot, type: Integer
    field :free_position_sog, type: Integer
    field :assist, type: Integer
    field :draw_control, type: Integer
    field :ground_ball, type: Integer
    field :interception, type: Integer
    field :turnover, type: Integer
    field :caused_turnover, type: Integer 			# STICK CHECK, BLOCKS, DRAWN CHARGE
    field :foul, type: Integer
    field :saves, type: Integer
    field :penalties, type: Integer

    field :minutesplayed, type: Integer
    field :goal_allowed, type: Integer

    field :goalie, type: Boolean

	belongs_to :athlete
	belongs_to :gameschedule

	has_many :alerts, dependent: :destroy
	has_many :gamelogs, dependent: :destroy

	index({ gameschedule: 1 }, { unique: true })

	validates_numericality_of :goals, greater_than_or_equal_to: 0
	validates_numericality_of :shot, greater_than_or_equal_to: 0
	validates_numericality_of :assist, greater_than_or_equal_to: 0
	validates_numericality_of :free_position_sog, greater_than_or_equal_to: 0
	validates_numericality_of :draw_control, greater_than_or_equal_to: 0
	validates_numericality_of :ground_ball, greater_than_or_equal_to: 0
	validates_numericality_of :interception, greater_than_or_equal_to: 0
	validates_numericality_of :turnover, greater_than_or_equal_to: 0
	validates_numericality_of :caused_turnover, greater_than_or_equal_to: 0
	validates_numericality_of :foul, greater_than_or_equal_to: 0
	validates_numericality_of :clear, greater_than_or_equal_to: 0
	validates_numericality_of :saves, greater_than_or_equal_to: 0
	validates_numericality_of :minutesplayed, greater_than_or_equal_to: 0

	def save_percentage
		self.save/(self.save + self.goal)
	end

	def goal_average
		(self.goal_allowed * 60) / self.minutesplayed
	end

	def shooting_accuracy
		self.goal / self.shot
	end

	def points_per_game
		self.goal + self.assist
	end

end
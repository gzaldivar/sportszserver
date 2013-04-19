class FootballStat
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :athlete
  belongs_to :gameschedule

  embeds_one :football_passings
  embeds_one :football_rushings
  embeds_one :football_defenses
  embeds_one :football_specialteams
  embeds_one :football_receivings

end

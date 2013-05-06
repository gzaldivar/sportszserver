class FootballStat
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :athlete
  belongs_to :gameschedule
  belongs_to :alerts

  embeds_one :football_passings
  embeds_one :football_rushings
  embeds_one :football_defenses
  embeds_one :football_receivings
  embeds_one :football_kickers
  embeds_one :football_returners

end

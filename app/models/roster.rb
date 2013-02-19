class Roster
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :team
#  embeds_many :athletes
end

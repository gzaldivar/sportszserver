class SoccerSub
	include Mongoid::Document
    include Mongoid::Timestamps

    field :inplayer, type: String
    field :outplayer, type: String
    field :gametime, type: String
    field :home, type: Boolean, default: true

    embedded_in :soccer_game

    validates :inplayer, presence: true
    validates :outplayer, presence: true
    validates :gametime, presence: true

    def get_inplayer
        playerin ||= Athlete.find(inplayer)
    end

    def get_outplayer
        playerout ||= Athlete.find(outplayer)
    end

    attr_accessor :playerin, :playerout

end
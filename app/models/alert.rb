class Alert
  include Mongoid::Document
  include Mongoid::Timestamps

  field :message, type: String

  belongs_to :athlete
  belongs_to :blog
  belongs_to :photo
  belongs_to :videoclip
  belongs_to :user
  belongs_to :sport

end

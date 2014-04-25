class Lastad
  include Mongoid::Document
  include Mongoid::Timestamps

  field :sponsor_id, type: String

  belongs_to :sport

end

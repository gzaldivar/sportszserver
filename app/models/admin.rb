class Admin
  include Mongoid::Document
  include Mongoid::Timestamps

  field :streamingurl, type: String
  field :streamingbucket, type: String
  field :disableads, type: Boolean, default: false
  field :highlightAppVersion, type: String
  field :broadcastAppVersion, type: String
  field :pricingurl, type: String, default: ""
  field :adurl, type: String, default: ""
  field :supportedsports, type: Array, default: ["Football", "Basketball", "Soccer"]
  field :adpercentage, type: Integer, default: 20

end

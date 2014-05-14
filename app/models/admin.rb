class Admin
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :streamingurl, type: String
  field :streamingbucket, type: String
  field :disableads, type: Boolean, default: false
  field :highlightAppVersion, type: String
  field :broadcastAppVersion, type: String
  field :pricingurl, type: String, default: ""
  field :adurl, type: String, default: ""
  field :supportedsports, type: Array, default: ["Football", "Basketball", "Soccer"]
  field :adpercentage, type: Integer, default: 20

  has_mongoid_attached_file :iPhonePemAPN,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
                         secret_access_key: S3DirectUpload.config.secret_access_key }

  has_mongoid_attached_file :iPadPemAPN,
    :storage        => :s3,
    :s3_credentials => { bucket: S3DirectUpload.config.bucket,
                         access_key_id: S3DirectUpload.config.access_key_id,
                         secret_access_key: S3DirectUpload.config.secret_access_key }

end

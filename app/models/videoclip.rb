class Videoclip
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  
  field :filename, type: String
  field :filepath, type: String
  field :filesize, type: String
  field :filetype, type: String

  field :video_url, type: String
  field :poster_url, type: String
  field :poster_filepath, type: String
  
  field :resolution,  type: String
  field :height,  type: Integer
  field :width, type: Integer
  field :size, type: Integer
  field :bitrate,   type: Integer
  field :duration, type: Float
  field :frame_rate, type: Float

  field :displayname, type: String
  field :description, type: String

  field :error_status, type: Boolean, default: false
  field :error_message, type: String

  field :teamid,  type: String
  field :schedule,  type: String
  field :owner, type: String
  field :players, type: Array
  
  search_in :players, :displayname
  
  belongs_to :sport
  
  index( { teamid: 1 }, { unique: false } )
  index( { schedule: 1 } , { unique: false } )
  index( { owner: 1 } , { unique: false } )

  validates_presence_of :filename

  def videopath
    "#{Rails.root}/tmp"
  end

  def deleteclips
    s3 = AWS::S3.new
    bucket = s3.buckets[S3DirectUpload.config.bucket]
    bucket.objects[self.filepath].delete
    bucket.objects[self.poster_filepath].delete
  end

end

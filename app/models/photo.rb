class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search

  after_save :send_alerts
  before_destroy :deletephoto
  
  field :filename, type: String
  field :filepath, type: String
  field :filesize, type: Integer
  field :filetype, type: String
  field :original_url, type: String
  field :large_url, type: String
  field :medium_url, type: String
  field :thumbnail_url, type: String
  field :displayname, type: String
  field :description, type: String
  field :processing, type: Boolean
  field :pending, type: Boolean
  field :error_status, type: Boolean
  
  field :teamid,  type: String
#  field :schedule,  type: String
#  field :owner, type: String
  field :players, type: Array
  
  index({ teamid: 1 }, { unique: false } )
#  index( { schedule: 1 } , { unique: false } )
  index( { owner: 1 } , { unique: false } )
  
  belongs_to :sport, index: true
  belongs_to :gameschedule
  belongs_to :user
  has_many :alerts
  
  validates_presence_of :filename
  validates_presence_of :filepath
  validates_presence_of :filesize
  validates_presence_of :filetype
  
  search_in :players, :displayname

  def photodir
    "#{Rails.root}/tmp"
  end

  def storephoto(uploaded_io)
    if uploaded_io.content_type == "image/jpeg"
      if !self.filename.nil?
        self.deletephoto
        self.large_url = nil
        self.medium_url = nil
        self.thumbnail_url = nil
      end
      self.filename = uploaded_io.original_filename
      self.filepath = s3_directory + "/original"
      self.filetype = uploaded_io.content_type
      s3 = AWS::S3.new
      bucket = s3.buckets[S3DirectUpload.config.bucket]
      obj = bucket.objects[s3_directory + '/original/' + self.filename]
      obj.write(uploaded_io.read)
      self.original_url = obj.url_for(:read, expires:  473040000)
      return self.filename
    else
      return nil
    end
  end

  def deletephoto
    s3 = AWS::S3.new
    bucket = s3.buckets[S3DirectUpload.config.bucket]
#    bucket.objects[self.filepath + "/original/" + self.filename].delete
    bucket.objects[self.filepath + "/large/" + self.filename].delete
    bucket.objects[self.filepath + "/medium/" + self.filename].delete
    bucket.objects[self.filepath + "/thumbnail/" + self.filename].delete
  end

  private

    def send_alerts
        if !self.players.nil?
            self.players.each do |p|
              player = Athlete.find(p)
              player.followers.each do |user, name|
                player.alerts.create!(user: user, photo: self.id)
              end
            end
        end
    end
  
end

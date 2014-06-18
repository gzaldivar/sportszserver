class PhotoProcessor
  require 'RMagick'
  
  @queue = :photos_queue
  
  def self.perform(photo_id)
    item = PhotoQueue.find(photo_id)
    
    puts "Starting job " + photo_id.to_s

    if item.modelname == "photos"
      photo = Photo.find(item.modelid)

      photopath = photo.photodir
      
      begin
        s3 = AWS::S3.new
        bucket = s3.buckets[S3DirectUpload.config.bucket]
        obj = bucket.objects[photo.filepath]
        img_path = photopath + "/" + SecureRandom.hex(10) + photo.filename
        
        File.open(img_path, 'wb') do |file|
          obj.read do |chunk|
            file.write(chunk)
          end
        end
        
        img = Magick::Image::read(img_path).first
        
        if img.format == 'JPEG'      
          if img.columns > img.rows
            thumb = img.scale(125, 125)
            medium = img.scale(512, 345)
            large = img.scale(1024, 680)
          else
            thumb = img.scale(125, 125)
            medium = img.scale(345, 512)
            large = img.scale(680, 1024)
          end
          
          # write thumbnail to S3
          
          tobj = bucket.objects[item.modelname + "/" + photo.id + "/thumbnail/" + photo.filename]
          temp_thumb_filename = photopath + "/" + SecureRandom.hex(10) + photo.id + ".jpg"
          thumb.write(temp_thumb_filename)
          tobj.write(Pathname.new(temp_thumb_filename))    # upload the thumbnail to S3
          photo.thumbnail_url = tobj.url_for(:read, expires:  473040000)
          photo.thumbsize = thumb.filesize
          
          # write medium to S3
          
          mobj = bucket.objects[item.modelname + "/" + photo.id + "/medium/" + photo.filename]
          temp_medium_filename = photopath + "/" + SecureRandom.hex(10) + photo.id + ".jpg"
          medium.write(temp_medium_filename)
          mobj.write(Pathname.new(temp_medium_filename))    # upload the medium to S3
          photo.medium_url = mobj.url_for(:read, expires:  473040000)
          photo.mediumsize = medium.filesize
          
          # write large to S3
          
          lobj = bucket.objects[item.modelname + "/" + photo.id + "/large/" + photo.filename]
          temp_large_filename = photopath + "/" + SecureRandom.hex(10) + photo.id + ".jpg"
          large.write(temp_large_filename)
          lobj.write(Pathname.new(temp_large_filename))    # upload the large to S3
          photo.large_url = lobj.url_for(:read, expires:  473040000)
          photo.largesize = large.filesize

          site = photo.sport 
          site.mediasize = site.mediasize + photo.largesize + photo.mediumsize + photo.thumbsize
          site.save
    
          # remove temporary files
          
          FileUtils.rm(temp_large_filename)
          FileUtils.rm(temp_medium_filename)
          FileUtils.rm(temp_thumb_filename)
          FileUtils.rm(img_path)
          
          if item.modelname == "photos"
  #          newobj = obj.move_to(item.modelname + "/" + photo.id + "/original/" + photo.filename)
            obj.delete
            photo.original_url = nil
            photo.processing = false
  #          photo.original_url = newobj.url_for(:read, expires:  473040000)
          end
          photo.filepath = item.modelname + '/' + photo.id
          
          item.delete
        else
          error = item.sport.photo_errors.new
          if item.modelname == "photos"
            photo.error_status = true
            obj.delete
          end
          error.error_message = "Photo must be a JPEG"
          error.modelname = item.modelname
          error.modelid = item.modelid
          error.sport = item.sport
          error.save
          item.delete
        end
        
        photo.save
      rescue Exception => e
        error = item.sport.photo_errors.new
        if item.modelname == "photos"
          photo.error_status = true
        end
        error.error_message = e.message
        error.modelname = item.modelname
        error.modelid = item.modelid
        error.sport = item.sport
        error.save
        photo.save
        item.delete
      end

    elsif item.modelname == "sponsors"
      begin
        puts 'processing sponsor'
        sponsor = Sponsor.find(item.modelid)    
        s3 = AWS::S3.new
        bucket = s3.buckets[S3DirectUpload.config.bucket]
        obj = bucket.objects[item.filepath]

        sponsor.image_data = obj.read
        sponsor.original_filename = item.filename
        sponsor.content_type = item.filetype
        sponsor.imagetype = "sponsorimage"
        sponsor.processing = false

        if (!sponsor.ios_client_ad.nil? and sponsor.ios_client_ad.playerad) or (!sponsor.sportadinv.nil? and sponsor.sportadinv.playerad)
          sponsor.save(validate: false)
        else
          sponsor.save!
        end
        
        obj.delete
        item.delete
      rescue Exception => e
        error = item.sport.photo_errors.new
        error.error_message = e.message
        error.modelname = item.modelname
        error.modelid = item.modelid
        error.sport = item.sport
        error.save
        item.delete
      end
    elsif item.modelname == "sponsorbanner"
      begin
        puts 'processing sponsor banner'
        sponsor = Sponsor.find(item.modelid)    
        s3 = AWS::S3.new
        bucket = s3.buckets[S3DirectUpload.config.bucket]
        obj = bucket.objects[item.filepath]

        sponsor.image_data = obj.read
        sponsor.original_filename = item.filename
        sponsor.content_type = item.filetype
        sponsor.imagetype = "sponsorbanner"
        sponsor.processing = false

        if (!sponsor.ios_client_ad.nil? and sponsor.ios_client_ad.playerad) or (!sponsor.sportadinv.nil? and sponsor.sportadinv.playerad)
          sponsor.save(validate: false)
        else
          sponsor.save!
        end
        
        obj.delete
        item.delete
      rescue Exception => e
        error = item.sport.photo_errors.new
        error.error_message = e.message
        error.modelname = item.modelname
        error.modelid = item.modelid
        error.sport = item.sport
        error.save
        item.delete
      end
    elsif item.modelname == "athletes"
      begin
        athlete = Athlete.find(item.modelid)    
        s3 = AWS::S3.new
        bucket = s3.buckets[S3DirectUpload.config.bucket]
        obj = bucket.objects[item.filepath]

        athlete.image_data = obj.read
        athlete.original_filename = item.filename
        athlete.content_type = item.filetype
        athlete.save!
        athlete.processing = false
        athlete.save!
        
        obj.delete
        item.delete
      rescue Exception => e
        error = item.sport.photo_errors.new
        error.error_message = e.message
        error.modelname = item.modelname
        error.modelid = item.modelid
        error.sport = item.sport
        error.save
        item.delete
      end
    elsif item.modelname == "coaches"
      begin
        coach = Coach.find(item.modelid)    
        s3 = AWS::S3.new
        bucket = s3.buckets[S3DirectUpload.config.bucket]
        obj = bucket.objects[item.filepath]

        coach.image_data = obj.read
        coach.original_filename = item.filename
        coach.content_type = item.filetype
        coach.processing = false
        coach.save!
        
        obj.delete
        item.delete
      rescue Exception => e
        error = item.sport.photo_errors.new
        error.error_message = e.message
        error.modelname = item.modelname
        error.modelid = item.modelid
        error.sport = item.sport
        error.save
        item.delete
      end
    elsif item.modelname == "newsfeeds"
      begin
        newsfeed = Newsfeed.find(item.modelid)    
        s3 = AWS::S3.new
        bucket = s3.buckets[S3DirectUpload.config.bucket]
        obj = bucket.objects[item.filepath]

        newsfeed.image_data = obj.read
        newsfeed.original_filename = item.filename
        newsfeed.content_type = item.filetype
        newsfeed.processing = false
        newsfeed.save!
        
        obj.delete
        item.delete
      rescue Exception => e
        error = item.sport.photo_errors.new
        error.error_message = e.message
        error.modelname = item.modelname
        error.modelid = item.modelid
        error.sport = item.sport
        error.save
        item.delete
      end
    elsif item.modelname == "sportlogo"
      begin
        sport = Sport.find(item.modelid)    
        s3 = AWS::S3.new
        bucket = s3.buckets[S3DirectUpload.config.bucket]
        obj = bucket.objects[item.filepath]

        sport.image_data = obj.read
        sport.original_filename = item.filename
        sport.content_type = item.filetype
        sport.logoprocessing = false
        sport.save!
        
        obj.delete
        item.delete
      rescue Exception => e
        error = item.sport.photo_errors.new
        error.error_message = e.message
        error.modelname = item.modelname
        error.modelid = item.modelid
        error.sport = item.sport
        error.save
        item.delete
      end
    elsif item.modelname == "teamlogo"
      begin
        sport = Sport.find(item.sport_id)
        team = sport.teams.find(item.modelid)    
        s3 = AWS::S3.new
        bucket = s3.buckets[S3DirectUpload.config.bucket]
        obj = bucket.objects[item.filepath]

        team.image_data = obj.read
        team.original_filename = item.filename
        team.content_type = item.filetype
        team.logoprocessing = false
        team.save!
        
        obj.delete
        item.delete
      rescue Exception => e
        error = item.sport.photo_errors.new
        error.error_message = e.message
        error.modelname = item.modelname
        error.modelid = item.modelid
        error.sport = item.sport
        error.save
        item.delete
      end
    elsif item.modelname == "gameschedulelogo"
      begin
        gameschedule = Gameschedule.find(item.modelid)
        s3 = AWS::S3.new
        bucket = s3.buckets[S3DirectUpload.config.bucket]
        obj = bucket.objects[item.filepath]

        gameschedule.image_data = obj.read
        gameschedule.original_filename = item.filename
        gameschedule.content_type = item.filetype
#        gameschedule.logoprocessing = false
        gameschedule.save!

        obj.delete
        item.delete
      rescue Exception => e
        error = item.sport.photo_errors.new
        error.error_message = e.message
        error.modelname = item.modelname
        error.modelid = item.modelid
        error.sport = item.sport
        error.save
        item.delete
      end
    elsif item.modelname == "useravatar"
      begin
        user = User.find(item.modelid)
        s3 = AWS::S3.new
        bucket = s3.buckets[S3DirectUpload.config.bucket]
        obj = bucket.objects[item.filepath]

        img_path = "#{Rails.root}/tmp/" + SecureRandom.hex(10) + user.name
        
        File.open(img_path, 'wb') do |file|
          obj.read do |chunk|
            file.write(chunk)
          end
        end
        
        img = Magick::Image::read(img_path).first

        if img.format == 'JPEG'      
          thumb = img.scale(125, 125)
          tiny = img.scale(50, 50)
        end
          
          # write thumbnail to S3

        tinyobj = bucket.objects["users/" + user.id + "/tiny/" + user.name]
        temp_tiny_filename = "#{Rails.root}/tmp/" + SecureRandom.hex(10) + user.id + ".jpg"
        tiny.write(temp_tiny_filename)
        tinyobj.write(Pathname.new(temp_tiny_filename))    # upload the thumbnail to S3
        user.avatartinyurl = tinyobj.url_for(:read, expires:  473040000)
          
        tobj = bucket.objects["users/" + user.id + "/thumbnail/" + user.name]
        temp_thumb_filename = "#{Rails.root}/tmp/" + SecureRandom.hex(10) + user.id + ".jpg"
        thumb.write(temp_thumb_filename)
        tobj.write(Pathname.new(temp_thumb_filename))    # upload the thumbnail to S3
        user.avatarthumburl = tobj.url_for(:read, expires:  473040000)

#        user.image_data = obj.read
#        user.original_filename = item.filename
#        user.content_type = item.filetype
        user.avatarprocessing = false
        user.save!
        
        FileUtils.rm(temp_tiny_filename)
        FileUtils.rm(temp_thumb_filename)

        obj.delete
        item.delete
      rescue Exception => e
        error = item.sport.photo_errors.new
        error.error_message = e.message
        error.modelname = item.modelname
        error.modelid = item.modelid
        error.sport = item.sport
        error.save
        item.delete
      end
    end
  end
  
end
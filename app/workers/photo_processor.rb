class PhotoProcessor
  require 'RMagick'
  
  @queue = :photos_queue
  
  def self.perform(photo_id)
    item = PhotoQueue.find(photo_id)
    
    if item.modelname == "photos"
      photo = Photo.find(item.modelid)
    end
    
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
          medium = img.scale(512, 374)
          large = img.scale(1024, 748)
        else
          thumb = img.scale(125, 125)
          medium = img.scale(320, 480)
          large = img.scale(640, 960)
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
  end
  
end
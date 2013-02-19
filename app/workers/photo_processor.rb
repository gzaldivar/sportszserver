class PhotoProcessor
  require 'RMagick'
  
  @queue = :photos_queue
  
  def self.perform(photo_id)
    item = PhotoQueue.find(photo_id)
    
    if item.modelname == "athletes"
      photo = Athlete.find(item.modelid)
    elsif item.modelname == "coaches"
      photo = Coach.find(item.modelid)
    elsif item.modelname == "photos"
      photo = Photo.find(item.modelid)
    end
    
    photopath = photo.photodir
    
    begin
      s3 = AWS::S3.new
      bucket = s3.buckets[S3DirectUpload.config.bucket]
      obj = bucket.objects[photo.filepath]
      img_path = photopath + "/temp/" + photo.filename
      
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
        thumb.write(photopath + "/thumb/" + photo.id + ".jpg")
        tobj.write(Pathname.new(photopath + "/thumb/" + photo.id + ".jpg"))    # upload the thumbnail to S3
        photo.thumbnail_url = tobj.url_for(:read, expires:  473040000)
        
        # write medium to S3
        
        mobj = bucket.objects[item.modelname + "/" + photo.id + "/medium/" + photo.filename]
        medium.write(photopath + "/medium/" + photo.id + ".jpg")
        mobj.write(Pathname.new(photopath + "/medium/" + photo.id + ".jpg"))    # upload the medium to S3
        photo.medium_url = mobj.url_for(:read, expires:  473040000)
        
        # write large to S3
        
        lobj = bucket.objects[item.modelname + "/" + photo.id + "/large/" + photo.filename]
        large.write(photopath + "/large/" + photo.id + ".jpg")
        lobj.write(Pathname.new(photopath + "/large/" + photo.id + ".jpg"))    # upload the large to S3
        photo.large_url = lobj.url_for(:read, expires:  473040000)
  
        # remove temporary files
        
        FileUtils.rm(photopath + "/thumb/" + photo.id + ".jpg")
        FileUtils.rm(photopath + "/medium/" + photo.id + ".jpg")
        FileUtils.rm(photopath + "/large/" + photo.id + ".jpg")
        FileUtils.rm(img_path)
        
        if item.modelname == "photos"
          newobj = obj.move_to(item.modelname + "/" + photo.id + "/original/" + photo.filename)
          photo.original_url = newobj.url_for(:read, expires:  473040000)
        end
        photo.filepath = item.modelname + '/' + photo.id + '/' + photo.filename
        
        if item.modelname == "photos"
          photo.processing = false
        end
        
        item.delete
      else
        error = PhotoError.new
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
      error = PhotoError.new
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
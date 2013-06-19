module base64_paperclip_upload

  attr_accessor :content_type, :original_filename, :image_data

  def decode_base64_image
    if self.image_data && self.content_type && self.original_filename
      decoded_data = Base64.decode64(self.image_data)

      data = StringIO.new(decoded_data)
      data.class_eval do
        attr_accessor :content_type, :original_filename
      end

      data.content_type = self.content_type
      data.original_filename = File.basename(self.original_filename)

      self.pic = data
    end
  end

end
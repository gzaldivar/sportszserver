if Rails.env.production?
	S3DirectUpload.config do |c|
		c.access_key_id = "AKIAIPCK7WD7Z53FKBEQ"       # your access key id
		c.secret_access_key = "HYnAlpoAjAug2JufK39/jDzyEdgnGLC9LA1WrT01"   # your secret access key
		c.bucket = "sportzteams"              # your bucket name
	end
else
	S3DirectUpload.config do |c|
		c.access_key_id = "AKIAJ5IHQGC3UPDHJZCA"       # your access key id
		c.secret_access_key = "aOosLpMFJ4xv51aMdrMF+6Mr1UhRXIzeIbmcb6+c"   # your secret access key
		c.bucket = "sportsite_solutions"              # your bucket name
	end
end
object @user
node(:id) { |o| o.id.to_s }
attributes :season, :bio_alert, :blog_alert, :stat_alert, :score_alert, :media_alert, :name, :email, :is_active, :admin, 
					:default_site, :teamid, :authentication_token, :avatarthumburl, :avatartinyurl, :avatarprocessing, :tier
node :adminsite, :if => lambda { |u| !u.adminsite.nil? } do |u|
	u.adminsite
end
# if lambda { |m| m.admin }
	node(:awskey) { S3DirectUpload.config.secret_access_key }
	node(:awskeyid) { S3DirectUpload.config.access_key_id }
# end

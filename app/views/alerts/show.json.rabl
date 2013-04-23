object @alert
node(:id) { |o| o.id.to_s }
attributes :message, :updated_at
node(:user) { |u| u.user_id.to_s }
node(:athlete) { |u| u.athlete_id.to_s }
node(:photo) { |u| u.photo_id.to_s }
node(:videoclip) { |u| u.videoclip_id.to_s }
node(:blog) { |u| u.blog_id.to_s }
node(:sport) { |u| u.sport_id.to_s }

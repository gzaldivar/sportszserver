object @sportadinv
node(:id) { |o| o.id.to_s }
attributes :price, :adlevelname, :active, :expiration
node (:sport_id) { |s| s.id.to_s }
node (:athlete_id) { |s| s.athlete_id.to_s }

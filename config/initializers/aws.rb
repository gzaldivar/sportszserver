if Rails.env.production?
	AWS.config({
	:access_key_id => 'AKIAIPCK7WD7Z53FKBEQ',
	:secret_access_key => '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',
	})
else
	AWS.config({
	:access_key_id => 'AKIAJ5IHQGC3UPDHJZCA',
	:secret_access_key => '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',
	})
end

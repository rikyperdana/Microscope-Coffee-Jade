@ownsDocument = (userId, doc) ->
	return doc && doc.userId is userId

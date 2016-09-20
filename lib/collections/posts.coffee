@Posts = new Mongo.Collection 'posts'

Posts.allow
	update: (userId, post) ->
		ownsDocument userId, post
	remove: (userId, post) ->
		ownsDocument userId, post

Posts.deny
  update: (userId, post, fieldNames) ->
    return (_.without(fieldNames, 'url', 'title').length > 0)

Posts.deny
  update: (userId, post, fieldNames, modifier) ->
    errors = validatePost(modifier.$set)
    return errors.title || errors.url

@validatePost = (post) ->
	errors = {}

	if not post.url
		errors.url = "Please fill in an URL"
	
	if not post.title
		errors.title = "Please fill a headline"
		
	return errors
	
Meteor.methods
	postInsert: (postAttributes) ->
		check this.userId, String
		check postAttributes,
			title: String
			url: String
		
		errors = validatePost postAttributes
		if errors.title || errors.url
			throw new Meteor.Error "invalid-post", "You must set a title and URL for your post"
		
		postWithSameLink = Posts.findOne {url: postAttributes.url}
		
		if postWithSameLink
			postExists: true
			_id: postWithSameLink._id
		
		user = Meteor.user()
		post = _.extend postAttributes,
			userId: user._id
			author: user.username
			submitted: new Date()
			commentsCount: 0
			upvoters: []
			votes: 0
		postId = Posts.insert post
		
		return _id: postId
	
	upvote: (postId) ->
		check this.userId, String
		check postId, String
		
		affected = Posts.update({
				_id: postId,
				upvoters: {$ne: this.userId}
			}, {
				$addToSet: {upvoters: this.userId},
				$inc: {votes: 1}
			})
			
		if not affected
			throw new Meteor.Error "invalid", "You weren't able to upvote that post"

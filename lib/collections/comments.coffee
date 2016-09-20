@Comments = new Mongo.Collection 'comments'

Meteor.methods
	commentInsert: (commentAttributes) ->
		check this.userId, String
		check commentAttributes,
			postId: String,
			body: String
		
		user = Meteor.user()
		post = Posts.findOne commentAttributes.postId
		
		if not post
			throw new Meteor.Error 'invalid-comment', 'You must comment'
		comment = _.extend commentAttributes,
			userId: user._id,
			author: user.username,
			submitted: new Date()
		
		Posts.update comment.postId, {$inc: {commentsCount: 1}}
		
		comment._id = Comments.insert comment
		
		createCommentNotification(comment)
		
		comment._id

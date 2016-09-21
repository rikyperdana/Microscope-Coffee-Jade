Router.configure
	layoutTemplate: 'layout'
	loadingTemplate: 'loading'
	notFoundTemplate: 'notFound'
	waitOn: ->
		Meteor.subscribe 'notifications'
    
PostsListController = RouteController.extend
	template: 'postsList'
	increment: 5
	postsLimit: ->
		parseInt(this.params.postsLimit) or this.increment
	findOptions: ->
			sort: this.sort
			limit: this.postsLimit()
	subscriptions: ->
		this.postsSub = Meteor.subscribe 'posts', this.findOptions()
		return
	posts: ->
		Posts.find {}, this.findOptions()
	data: ->
		self = this
		output =
			posts: self.posts()
			ready: self.postsSub.ready
			nextPath: ->
				if self.posts().count() is self.postsLimit()
					self.nextPath()
		output


@NewPostsController = PostsListController.extend
	sort:
		submitted: -1
		_id: -1
	nextPath: ->
		Router.routes.newPosts.path
			postsLimit: this.postsLimit() + this.increment


@BestPostsController = PostsListController.extend
	sort:
		votes: -1
		submitted: -1
		_id: -1
	nextPath: ->
		Router.routes.bestPosts.path
			postsLimit: this.postsLimit() + this.increment


Router.route '/',
	name: 'home'
	controller: NewPostsController

Router.route '/new/:postsLimit?',
	name: 'newPosts'

Router.route '/best/:postsLimit?',
	name: 'bestPosts'

Router.route '/posts/:_id',
  name: 'postPage'
  waitOn: ->
      Meteor.subscribe 'singlePost', this.params._id
      Meteor.subscribe 'comments', this.params._id
  data: ->
    Posts.findOne this.params._id

Router.route '/posts/:_id/edit',
	name: 'postEdit'
	waitOn: ->
		Meteor.subscribe 'singlePost', this.params._id
	data: ->
		Posts.findOne this.params._id

Router.route '/submit',
	name: 'postSubmit'

@requireLogin = ->
	if not Meteor.user()
		if Meteor.loggingIn()
			this.render this.loadingTemplate
		else
			this.render 'accessDenied'
	else
		this.next()

Router.onBeforeAction 'dataNotFound',
	only: 'postPage'

Router.onBeforeAction requireLogin,
	only: 'postSubmit'
###
###

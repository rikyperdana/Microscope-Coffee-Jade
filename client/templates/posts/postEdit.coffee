Template.postEdit.onCreated ->
	Session.set 'postEditErrors', {}

Template.postEdit.helpers
	errorMessage: (field) ->
		Session.get('postEditErrors')[field]
	errorClass: (field) ->
		!! Session.get('postEditErrors')[field] ? 'has-error' : ''

Template.postEdit.events
	'submit form': (e) ->
		e.preventDefault()
		currentPostId = this._id
		postProperties =
			url: $(e.target).find('[name=url]').val()
			title: $(e.target).find('[name=title]').val()
		errors = validatePost postProperties
		if errors.title || errors.url
			Session.set 'postEditErrors', errors
		Posts.update currentPostId,
			$set: postProperties,
			(error) ->
				if error
					throwError error.reason
				else
					Router.go 'postPage',
						_id: currentPostId
	'click .delete': (e) ->
		e.preventDefault()
		if confirm "Delete this Post?"
			currentPostId = this._id
			Posts.remove currentPostId
			Router.go 'home'

Template.postSubmit.onCreated ->
	Session.set 'postSubmitErrors', {}

Template.postSubmit.helpers
	errorMessage: (field) ->
		Session.get('postSubmitErrors')[field]
	errorClass: (field) ->
		!! Session.get('postSubmitErrors')[field] ? 'has-error' : ''

Template.postSubmit.events
	'submit form': (e) ->
		e.preventDefault()
		post =
			url: $(e.target).find('[name=url]').val()
			title: $(e.target).find('[name=title]').val()
		errors = validatePost post
		if errors.title or errors.url
			Session.set 'postSubmitErrors', errors
		Meteor.call 'postInsert', post, (error, result) ->
			if error
				throwError error.reason
			if result.postExists
				throwError 'This link has already been posted'
			Router.go 'postPage',
				_id: result._id

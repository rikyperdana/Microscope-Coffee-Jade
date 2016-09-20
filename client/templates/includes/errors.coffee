Template.errors.helpers
	errors: ->
		Errors.find()

Template.error.onRendered ->
	error = this.data
	Meteor.setTimeout ->
		Errors.remove error._id
		3000

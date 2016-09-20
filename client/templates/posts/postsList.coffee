Template.postsList.onRendered ->
	this.find('.wrapper')._uihooks =
		insertElement: (node, next) ->
			$(node)
			.hide()
			.insertBefore next
			.fadeIn()
		moveElement: (node, next) ->
			$node = $(node)
			$next = $(next)
			oldTop = $node.offset().top
			height = $(node).outerHeight true
			$inBetween = $(next).nextUntil node
			if $inBetween.length is 0
				$inBetween = $(node).nextUntil next
			$(node).insertBefore next
			newTop = $(node).offset().top
			$(node)
				.removeClass 'animate'
				.css('top', oldTop - newTop)
			$inBetween
				.removeClass 'animate'
				.css('top', oldTop < newTop ? height : -1 * height)
			$(node).offset()
			$(node).addClass('animate').css('top', 0)
			$inBetween.addClass('animate').css('top', 0)
		removeElement: (node) ->
			$(node).fadeOut ->
				$(this).remove()

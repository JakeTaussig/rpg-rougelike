extends RichTextLabel
class_name MarkTracker

var click_counter = 0

func _gui_input(event: InputEvent) -> void:
	# TODO: Make this do-able with controller - be able to cycle through enemy tracker and press RB to switch the marking. 
	if event.is_action_pressed("mark_tracker") and not get_parent().get_parent().get_parent().is_player:
		click_counter += 1
		if click_counter > 3:
			click_counter = 1
		match click_counter:
			1:
				text = "+"
				add_theme_color_override("font_color", Color.GREEN)
			2:
				text = "="
				add_theme_color_override("font_color", Color.WHITE)
			3:
				text = "-"
				add_theme_color_override("font_color", Color.RED)

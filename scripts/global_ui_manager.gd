class_name GlobalUIManager
extends Node

const dark_blue_border_color = Color(0.071, 0.306, 0.537, 1.0)
const white = Color(1.0, 1.0, 1.0, 1.0)
# ui references
@onready var floor_progress_display = %FloorProgressDisplay
@onready var floor_progress_descriptions = %FloorProgressDescriptions


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func reset_ui_elements():
	# reset the first event button to base styling
	var event_icon_button: Button = floor_progress_display.get_child(0)
	event_icon_button.set_pressed(false)
	event_icon_button.z_index = 1
	event_icon_button.add_theme_stylebox_override("normal", load("res://assets/styles/room_event_button_normal.tres"))
	event_icon_button.add_theme_stylebox_override("hover", load("res://assets/styles/room_event_button_normal.tres"))

	# reset the first event description to base styling
	var description_label: Label = floor_progress_descriptions.get_child(0)
	description_label.hide()
	description_label.add_theme_color_override("font_color", white)
	description_label.add_theme_stylebox_override("normal", load("res://assets/styles/shop_button.tres"))

	# Remove existing icons and labels for events
	for child in %FloorProgressDisplay.get_children():
		%FloorProgressDisplay.remove_child(child)
	for child in floor_progress_descriptions.get_children():
		floor_progress_descriptions.remove_child(child)

	for i in range(GameManager.floor_event_count):
		var event = GameManager.floor_events[i]
		var duplicate_icon_button: Button = event_icon_button.duplicate(DUPLICATE_USE_INSTANTIATION)
		var event_type = ""
		if event is Shop:
			duplicate_icon_button.icon = load("res://assets/sprites/room_icons/shop.png")
			event_type = "Shop"
		elif event is Battle:
			duplicate_icon_button.icon = load("res://assets/sprites/room_icons/battle.png")
			event_type = "Battle"

		%FloorProgressDisplay.add_child(duplicate_icon_button)

		var duplicate_label = description_label.duplicate()
		duplicate_label.text = "Room %d / %d: %s" % [i + 1, GameManager.floor_event_count, event_type]
		floor_progress_descriptions.add_child(duplicate_label)

		# mouse_entered handler: show labels for events (excluding the next
		# upcoming event, which already has its label showing).
		duplicate_icon_button.mouse_entered.connect(func():
			if i < GameManager.floor_event_index:
				duplicate_label.add_theme_stylebox_override("normal", load("res://assets/styles/shop_button.tres"))
				duplicate_label.add_theme_color_override("font_color", white)
			duplicate_label.show()
		)

		# mouse_exited handler: hide labels. for already completed events, make
		# the label the same color as the background to not affect layout
		duplicate_icon_button.mouse_exited.connect(func():
			if i > GameManager.floor_event_index:
				duplicate_label.hide()
			if i < GameManager.floor_event_index:
				duplicate_label.add_theme_stylebox_override("normal", load("res://assets/styles/shop_button_border_color.tres"))
				duplicate_label.add_theme_color_override("font_color", dark_blue_border_color)
		)


func update_ui_text():
	var next_event = GameManager.floor_events[0]
	var next_event_type = ""
	var next_event_icon
	if next_event is Shop:
		next_event_type = "Shop"
		next_event_icon = load("res://assets/sprites/room_icons/shop.png")
	if next_event is Battle:
		next_event_type = "Battle"
		next_event_icon = load("res://assets/sprites/room_icons/battle.png")

	%UpNext.text = "Up next: %s" % next_event_type
	%NextRoomIcon.texture = next_event_icon
	%FloorName.text = "Floor %d" % GameManager.floor_number


# This function is intended to be called after an event has been unloaded and
# before floor_event_index has been incremented
func hide_ui_elements():
	# press the icon button for the event, changing the background color
	floor_progress_display.get_child(GameManager.floor_event_index).set_pressed(true)
	%ContinueButton.disabled = true

	# Make the label for the recently unloaded event invisible
	var event_label: Label = floor_progress_descriptions.get_child(GameManager.floor_event_index)
	event_label.add_theme_stylebox_override("normal", load("res://assets/styles/shop_button_border_color.tres"))
	event_label.add_theme_color_override("font_color", dark_blue_border_color)

	%FloorProgressDisplay.hide()
	floor_progress_descriptions.hide()
	%Title.hide()
	%UpNext.hide()
	%NextRoomPanel.hide()
	%FloorName.hide()


func show_ui_elements():
	%FloorProgressDisplay.show()
	floor_progress_descriptions.show()
	floor_progress_descriptions.get_child(GameManager.floor_event_index).show()
	%Title.show()
	%UpNext.show()
	%NextRoomPanel.show()
	%FloorName.show()

	# Make the button for the next event highlighted
	var event_button: Button = %FloorProgressDisplay.get_child(GameManager.floor_event_index)
	event_button.add_theme_stylebox_override("normal", load("res://assets/styles/room_event_button_active.tres"))
	event_button.add_theme_stylebox_override("hover", load("res://assets/styles/room_event_button_active.tres"))
	event_button.z_index = 2

	# Show any trinkets the player has obtained since last time
	%TrinketShelf.render_trinkets()
	

func fade_in_loading_screen():
	%LoadingScreen/QuoteDisplay.text = GameManager.quotes.pop_back().text
	var panel = %LoadingScreen
	var tween = create_tween()
	
	panel.visible = true
	panel.modulate.a = 0.0
	
	# Fade in over 2.5 seconds
	tween.tween_property(panel, "modulate:a", 1.0, 2.5)
	await tween.finished
	
func wait_and_fade_out_loading_screen() -> void:
	var panel := %LoadingScreen
	if !is_instance_valid(panel):
		return

	panel.visible = true
	panel.modulate.a = 1.0

	# Wait 2s even if paused
	await get_tree().create_timer(8.0, false, false, true).timeout

	# Create tween bound to THIS node (which processes always)
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 2.5)

	await tween.finished
	panel.hide()


func hide_player_and_enemy():
	GameManager.player.hide()
	GameManager.enemy.hide()

func show_player_and_enemy():
	GameManager.player.show()
	GameManager.enemy.show()

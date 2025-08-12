extends Control

@onready var moves_menu = %MovesMenu

var last_focused_move_index: int = 0


func enter(on_move_pressed: Callable, is_move_disabled: Callable):
	var move_buttons = moves_menu.get_children()
	for i in GameManager.player.selected_monster.moves.size():
		var move = GameManager.player.selected_monster.moves[i]

		move_buttons[i].text = move.move_name
		move_buttons[i].focus_entered.connect(func(): _display_pp_info(i, is_move_disabled))
		move_buttons[i].mouse_entered.connect(move_buttons[i].grab_focus)
		move_buttons[i].pressed.connect(
			func():
				on_move_pressed.call(i)
				_display_pp_info(i, is_move_disabled)
		)

		if is_move_disabled.call(move):
			move_buttons[i].set_theme_type_variation("DisabledButton")
		else:
			move_buttons[i].set_theme_type_variation("Button")

	move_buttons[last_focused_move_index].grab_focus()


func exit():
	var move_buttons = moves_menu.get_children()
	for button: Button in move_buttons:
		for dict in button.get_signal_connection_list("pressed"):
			button.disconnect("pressed", dict.callable)
		for dict in button.get_signal_connection_list("focus_entered"):
			button.disconnect("focus_entered", dict.callable)
		for dict in button.get_signal_connection_list("mouse_entered"):
			button.disconnect("mouse_entered", dict.callable)


func disable_all_buttons():
	for move_button in moves_menu.get_children():
		move_button.set_theme_type_variation("DisabledButton")


# callback used when a move is focused
# displays the PP and type of the move in $"Moves/MovesInfo"
func _display_pp_info(move_index: int, is_move_disabled: Callable) -> void:
	last_focused_move_index = move_index

	var move = GameManager.player.selected_monster.moves[move_index]

	var text = "%d / %d" % [move.pp, move.max_pp]
	var disabled: bool = is_move_disabled.call(move)
	set_pp_info(text, disabled)

	set_type_info(move.type, disabled)
	set_move_power(move.base_power, disabled)
	set_move_accuracy(move.acc, disabled)


func set_pp_info(text: String, disabled: bool):
	var pp_display = %PPInfo
	var pp_label = get_node("MoveInfo/InfoContainer/PPInfoLabel")
	pp_display.text = text
	if disabled:
		pp_display.set_theme_type_variation("SmallTextRedTextLabel")
		pp_label.set_theme_type_variation("SmallTextRedTextLabel")

	else:
		pp_display.set_theme_type_variation("TinyTextLabel")
		pp_label.set_theme_type_variation("TinyTextLabel")


func set_type_info(type: MovesList.Type, disabled: bool):
	var type_info = get_node("MoveInfo/InfoContainer/TypeInfo")
	var type_label = get_node("MoveInfo/InfoContainer/TypeInfoLabel")

	var text = MovesList.Type.keys()[type]
	type_info.text = text

	if disabled:
		type_info.set_theme_type_variation("SmallTextDisabledLabel")
		type_label.set_theme_type_variation("SmallTextDisabledLabel")
		type_info.remove_theme_color_override("font_color")
	else:
		type_info.set_theme_type_variation("TinyTextLabel")
		type_label.set_theme_type_variation("TinyTextLabel")

		var type_color = MovesList.type_to_color(type)
		type_info.add_theme_color_override("font_color", type_color)


func set_move_power(power: int, disabled: bool):
	var power_display = get_node("MoveInfo/InfoContainer/Power")
	var power_label = get_node("MoveInfo/InfoContainer/PowerLabel")
	power_display.text = "%d" % power
	if disabled:
		power_display.set_theme_type_variation("SmallTextDisabledLabel")
		power_label.set_theme_type_variation("SmallTextDisabledLabel")
	else:
		power_display.set_theme_type_variation("TinyTextLabel")
		power_label.set_theme_type_variation("TinyTextLabel")


func set_move_accuracy(acc: int, disabled: bool):
	var acc_display = get_node("MoveInfo/InfoContainer/Acc")
	var acc_label = get_node("MoveInfo/InfoContainer/AccLabel")
	acc_display.text = "%d" % acc
	if disabled:
		acc_display.set_theme_type_variation("SmallTextDisabledLabel")
		acc_label.set_theme_type_variation("SmallTextDisabledLabel")
	else:
		acc_display.set_theme_type_variation("TinyTextLabel")
		acc_label.set_theme_type_variation("TinyTextLabel")

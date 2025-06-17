extends BaseState

var last_focused_item_index = 0

func enter(_messages: Array = []):
	battle.ui_manager.show_items_menu(true)
	call_deferred("_render_items")
	call_deferred("_refocus")

	# If we return to SELECTING_ITEM from SELECTING_ATTACK_PP_RESTORE,
	# (i.e. the player didn't choose a move and went back)
	# give them their item back
	if _messages.size() != 0 && _messages[0] == "replenish":
		%Player.items[last_focused_item_index].qty += 1

func _refocus():
	var child_count = %ItemsMenu.get_child_count()
	if last_focused_item_index >= child_count:
		last_focused_item_index = child_count - 1

	if last_focused_item_index <= -1:
		battle.ui_manager.focus_items_back_button()
		return

	battle.ui_manager.get_item_buttons()[last_focused_item_index].grab_focus()

func exit():
	battle.ui_manager.show_items_menu(false)
	for button: Button in battle.ui_manager.get_item_buttons():
		for dict in button.get_signal_connection_list("pressed"):
			button.disconnect("pressed", dict.callable)
		for dict in button.get_signal_connection_list("focus_entered"):
			button.disconnect("focus_entered", dict.callable)
		for dict in button.get_signal_connection_list("mouse_entered"):
			button.disconnect("mouse_entered", dict.callable)

func handle_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		battle.transition_state_to(battle.STATE_SELECTING_ACTION)

func _render_items():
	# Clear existing items first (except the first one which has focus signals)
	while battle.ui_manager.get_item_buttons().size() > 1:
		battle.ui_manager.get_item_buttons()[1].free()

	for i in GameManager.player.items.size():
		var item_button = battle.ui_manager.get_item_buttons()[0]
		if i != 0:
			item_button = item_button.duplicate()
			item_button.focus_neighbor_top = NodePath("")
			battle.ui_manager.add_item_button(item_button)

		item_button.text = GameManager.player.items[i].name
		item_button.focus_entered.connect(func(): _display_qty_info(i))
		item_button.mouse_entered.connect(item_button.grab_focus)
		item_button.pressed.connect(func(): _on_item_pressed(i))
		item_button.set_theme_type_variation("Button")

# callback used when a item is focused
# displays the PP and type of the item in $"items/ItemsInfo"
func _display_qty_info(item_index: int) -> void:
	last_focused_item_index = item_index

	battle.ui_manager.set_item_qty_info("%d / 99" % GameManager.player.items[item_index].qty)
	battle.ui_manager.set_item_type_info(GameManager.player.items[item_index].description)

func _on_item_pressed(item_index: int) -> void:
	var item = GameManager.player.items[item_index]
	item.consume(GameManager.player.selected_monster, battle)

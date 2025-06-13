extends BaseState

var last_focused_item_index = 0

func enter(_messages: Array = []):
	battle.ui_manager.show_items_menu(true)
	_render_items()
	call_deferred("_refocus")

	# If we return to SELECTING_ITEM from SELECTING_ATTACK_PP_RESTORE,
	# (i.e. the player didn't choose a move and went back)
	# give them their item back
	if _messages.size() != 0 && _messages[0] == "replenish":
		items[last_focused_item_index].qty += 1

func _refocus():
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
	# placeholder implementation
	var menu_buttons = battle.ui_manager.get_item_buttons()
	for i in items.size():
		var menu_button
		if i < menu_buttons.size():
			menu_button = menu_buttons[i]
		else:
			# duplicate the second menu button, because the first has focus signals connected to the back button
			menu_button = menu_buttons[1].duplicate()
			%ItemsMenu.add_child(menu_button)

		menu_button.text = items[i].name
		menu_button.focus_entered.connect(func(): _display_qty_info(i))
		menu_button.mouse_entered.connect(menu_button.grab_focus)
		menu_button.pressed.connect(func(): _on_item_pressed(i))

# callback used when a item is focused
# displays the PP and type of the item in $"items/ItemsInfo"
func _display_qty_info(item_index: int) -> void:
	last_focused_item_index = item_index

	battle.ui_manager.set_item_qty_info("%d / 99" % items[item_index].qty)
	battle.ui_manager.set_item_type_info(items[item_index].description)

func _on_item_pressed(item_index: int) -> void:
	var item = items[item_index]
	if item.qty > 0:
		item.callback.call()
		item.qty -= 1

var items: Array[Item] = []

func _ready():
	var selected_monster = GameManager.player.selected_monster

	var hp_restore = Item.create("HP restore", 5, "Heals 30 HP", func():
		const HP_RESTORE_AMT = 30
		selected_monster.hp += HP_RESTORE_AMT
		battle.transition_state_to(battle.STATE_INFO, ["%s restored 30 HP" % selected_monster.character_name])
		)

	var attack_up = Item.create("Attack Up", 5, "Boosts attack by 10%", func():
		const ATK_UP_FACTOR = 1.1
		var prior_atk = selected_monster.atk
		var current_atk = int(ATK_UP_FACTOR * prior_atk)
		selected_monster.atk = current_atk
		battle.transition_state_to(battle.STATE_INFO, ["%s's attack increased from %d to %d" % [selected_monster.character_name, prior_atk, current_atk]])
		)

	var sp_atk_up = Item.create("Sp. Atk Up", 5, "Boosts special attack by 10%", func():
		const SP_ATK_UP_FACTOR = 1.1
		var prior_sp_atk = selected_monster.sp_atk
		var current_sp_atk = int(SP_ATK_UP_FACTOR * prior_sp_atk)
		selected_monster.sp_atk = current_sp_atk
		battle.transition_state_to(battle.STATE_INFO, ["%s's special attack increased from %d to %d" % [selected_monster.character_name, prior_sp_atk, current_sp_atk]])
		)

	var def_up = Item.create("Def. Up", 5, "Boosts def. by 10%", func():
		const DEF_UP_FACTOR = 1.1
		var prior_def = selected_monster.def
		var current_def = int(DEF_UP_FACTOR * prior_def)
		selected_monster.def = current_def
		battle.transition_state_to(battle.STATE_INFO, ["%s's defense increased from %d to %d" % [selected_monster.character_name, prior_def, current_def]])
		)

	var sp_def_up = Item.create("Sp. Def Up", 5, "Boosts special def. by 10%", func():
		const SP_DEF_UP_FACTOR = 1.1
		var prior_sp_def = selected_monster.sp_def
		var current_sp_def = int(SP_DEF_UP_FACTOR * prior_sp_def)
		selected_monster.sp_def = current_sp_def
		battle.transition_state_to(battle.STATE_INFO, ["%s's special defense increased from %d to %d" % [selected_monster.character_name, prior_sp_def, current_sp_def]])
		)

	var speed_up = Item.create("Speed Up", 5, "Boosts speed by 10%", func():
		const SPEED_UP_FACTOR = 1.1
		var prior_speed = selected_monster.speed
		var current_speed = int(SPEED_UP_FACTOR * prior_speed)
		selected_monster.speed = current_speed
		battle.transition_state_to(battle.STATE_INFO, ["%s's speed increased from %d to %d" % [selected_monster.character_name, prior_speed, current_speed]])
		)

	var luck_up = Item.create("Luck Up", 5, "Boosts luck by 10%", func():
		const LUCK_UP_FACTOR = 1.1
		var prior_luck = selected_monster.luck
		var current_luck = int(LUCK_UP_FACTOR * prior_luck)
		selected_monster.luck = current_luck
		battle.transition_state_to(battle.STATE_INFO, ["%s's luck increased from %d to %d" % [selected_monster.character_name, prior_luck, current_luck]])
		)

	var burn_heal = Item.create("Aloe Vera", 8, "Heals player from BURN", func():
		if selected_monster.status_effect == MovesList.StatusEffect.BURN:
			selected_monster.recover_from_status_effect()
			battle.transition_state_to(battle.STATE_INFO, ["%s healed their BURN" % selected_monster.character_name])
		)

	var cripple_heal = Item.create("Pain Meds", 8, "Heals player from CRIPPLE", func():
		if selected_monster.status_effect == MovesList.StatusEffect.CRIPPLE:
			selected_monster.recover_from_status_effect()
			battle.transition_state_to(battle.STATE_INFO, ["%s recovered from CRIPPLE" % selected_monster.character_name])
		)

	var whirlpool_heal = Item.create("Lifeguard", 8, "Save plyr. from WHIRLPOOL", func():
		if selected_monster.status_effect == MovesList.StatusEffect.WHIRLPOOL:
			selected_monster.recover_from_status_effect()
			battle.transition_state_to(battle.STATE_INFO, ["%s escaped the WHIRLPOOL" % selected_monster.character_name])
		)

	var poison_heal = Item.create("Antidote", 8, "Cures player from POISON", func():
		if selected_monster.status_effect == MovesList.StatusEffect.POISON:
			selected_monster.recover_from_status_effect()
			battle.transition_state_to(battle.STATE_INFO, ["%s was cured of POISON" % selected_monster.character_name])
		)

	var paralyze_heal = Item.create("Paralyze Heal", 8, "Heals player from PARALYZE", func():
		if selected_monster.status_effect == MovesList.StatusEffect.PARALYZE:
			selected_monster.recover_from_status_effect()
			battle.transition_state_to(battle.STATE_INFO, ["%s recovered from PARALYZE" % selected_monster.character_name])
		)

	var consume_heal = Item.create("Antibiotics", 8, "Frees player from CONSUME", func():
		if selected_monster.status_effect == MovesList.StatusEffect.CONSUME:
			selected_monster.recover_from_status_effect()
			battle.transition_state_to(battle.STATE_INFO, ["%s regained their energy" % selected_monster.character_name])
		)

	var blind_heal = Item.create("Eye Drops", 8, "Cures player from BLIND", func():
		if selected_monster.status_effect == MovesList.StatusEffect.BLIND:
			selected_monster.recover_from_status_effect()
			battle.transition_state_to(battle.STATE_INFO, ["%s's vision was restored" % selected_monster.character_name])
		)

	var pp_restore = Item.create("PP Restore", 8, "Restore a move's PP", func():
		var all_moves_full_pp = true
		for move: Move in selected_monster.moves:
			if move.pp < move.max_pp:
				all_moves_full_pp = false
				break

		if all_moves_full_pp:
			return

		battle.transition_state_to(battle.STATE_SELECTING_ATTACK_PP_RESTORE)
		)
	items = [
		hp_restore,
		attack_up,
		sp_atk_up,
		def_up,
		sp_def_up,
		speed_up,
		luck_up,
		burn_heal,
		cripple_heal,
		whirlpool_heal,
		poison_heal,
		paralyze_heal,
		consume_heal,
		blind_heal,
		pp_restore
	]

class Item:
	var name: String
	var qty: int
	var description: String
	var callback: Callable

	static func create(_name: String, _qty: int, _description: String, _callback: Callable):
		var output = Item.new()
		output.name = _name
		output.qty = _qty
		output.description = _description
		output.callback = _callback
		return output

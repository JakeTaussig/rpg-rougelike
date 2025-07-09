extends Control

var _alphabetized_moves_list: Array[Move]

func _ready() -> void:
	if !get_parent().PROCESS_MODE_PAUSABLE:
		push_warning("warning: parent is not pausable")

	_alphabetized_moves_list = GameManager.moves_list.moves.duplicate()
	_alphabetized_moves_list.sort_custom(_sort_moves_alphabetically)

	_render_moves_list()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	var paused := not get_tree().paused
	get_tree().paused = paused
	visible = paused

func _render_moves_list():
	%MovesList.create_item()
	%MovesList.set_column_title(0, "name")
	%MovesList.set_column_title(1, "type")
	%MovesList.set_column_title(2, "pwr")
	%MovesList.set_column_title(3, "acc")

	%MovesList.set_column_expand(0, true)
	%MovesList.set_column_expand_ratio(0, 2)

	for move in _alphabetized_moves_list:
		var moveItem: TreeItem = %MovesList.create_item()

		moveItem.set_text(0, move.move_name)

		moveItem.set_text(1, MovesList.Type.keys()[move.type])
		moveItem.set_custom_color(1, MovesList.type_to_color(move.type))
		moveItem.set_text(2, str(move.base_power))
		moveItem.set_text(3, str(move.acc))

	%MovesList.item_selected.connect(func(): _on_debug_move_pressed())

func _sort_moves_alphabetically(a: Move, b: Move) -> bool:
	if a.move_name < b.move_name:
		return true
	return false

func _on_debug_move_pressed():
	var move_index: int = %MovesList.get_selected().get_index()
	var move: Move = _alphabetized_moves_list[move_index]
	print("\tuser input (DEBUG):\t\tselect DEBUG move %s" % [move.move_name])
	if move.pp > 0:
		var attackCommand = AttackState.AttackCommand.new()
		attackCommand.attacker = GameManager.player.selected_monster
		attackCommand.move_index = -1
		attackCommand._debug_move = move
		attackCommand.target = GameManager.enemy.selected_monster
		GameManager.current_battle.transition_state_to(GameManager.current_battle.STATE_ATTACK, [attackCommand])
		toggle_pause()

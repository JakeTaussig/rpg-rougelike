extends BaseState

var last_focused_move_index: int = 0

func enter(messages: Array = []):
	%Moves.visible = true
	%MovesMenu.get_child(last_focused_move_index).grab_focus()
	_render_moves()

func exit():
	%Moves.visible = false

func _render_moves():
	for i in %Player.moves.size():
		var move = %Player.moves[i]
		if move.pp <= 0:
			%MovesMenu.get_child(i).set_theme_type_variation("DisabledButton")
		else:
			%MovesMenu.get_child(i).set_theme_type_variation("Button")

func _on_move_pressed(index: int) -> void:
	var move = %Player.moves[index]
	if move.pp > 0:
		var attackCommand = AttackState.AttackCommand.new()
		attackCommand.attacker = %Player
		attackCommand.move_index = index
		attackCommand.target = battle.enemies[0]
		battle.transition_state_to(
			battle.STATE_ATTACK, battle.STATE_SELECTING_ATTACK,
			[attackCommand])

func _ready() -> void:
	_init_move_buttons()

# initialize move names and connect PP info display
func _init_move_buttons():
	for i in %Player.moves.size():
		%MovesMenu.get_child(i).text = %Player.moves[i].move_name
		%MovesMenu.get_child(i).focus_entered.connect(func(): _display_pp_info(i))
		%MovesMenu.get_child(i).mouse_entered.connect(%MovesMenu.get_child(i).grab_focus)

# callback used when a move is focused
# displays the PP and type of the move in $"Moves/MovesInfo"
func _display_pp_info(move_index: int) -> void:
	last_focused_move_index = move_index
	var move = %Player.moves[move_index]
	%PPInfo.text = "%d / %d" % [move.pp, move.max_pp]
	if move.pp <= 0:
		%PPInfo.set_theme_type_variation("RedTextLabel")
	else:
		%PPInfo.set_theme_type_variation("NoBorderLabel")
	%TypeInfo.text = MovesList.Type.keys()[move.type]

extends Node2D
var moves_list = MovesList.new()
var turn: int = 0
var turn_order_index: int = 0
var battle_participants = []
enum State {SELECTING_ACTION, SELECTING_ATTACK, ENEMY_ATTACK, ATTACKING_INFO, GAME_END}
var state: State = State.SELECTING_ACTION

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_battle_participants()
	_init_moves()
	_render_hp()
	for i in %Player.moves.size():
		%MovesMenu.get_child(i).text = %Player.moves[i].move_name
	if battle_participants[turn_order_index].is_player:
		_update_state(State.SELECTING_ACTION, "What will %s do?" % %Player.character_name)
	else:
		_update_state(State.ENEMY_ATTACK)

# The label_text can be turned into an Array of strings if we end up needing to pass multiple messages.
func _update_state(new_state: State, label_text: String = ""):
	var old_state = state
	state = new_state
	%StateDisplay.text = State.keys()[state]

	if old_state == State.SELECTING_ACTION:
		%PlayerPrompt.visible = false
		%Action.visible = false
	elif old_state == State.SELECTING_ATTACK:
		%Moves.visible = false
	elif old_state == State.ATTACKING_INFO:
		%BattleStatus.visible = false
		if %Enemy.hp <= 0:
			%BattleStatus.text = "%s defeated %s" % [%Player.character_name, %Enemy.character_name]
			_update_state(State.GAME_END)
			return
		elif %Player.hp <= 0:
			%BattleStatus.text = "%s defeated %s" % [%Enemy.character_name, %Player.character_name]
			_update_state(State.GAME_END)
			return

	if state == State.SELECTING_ACTION:
		%PlayerPrompt.visible = true
		%PlayerPrompt.text = label_text
		%Action.visible = true
		%Action.get_child(0).grab_focus()
	elif state == State.SELECTING_ATTACK:
		_render_moves()
		%Moves.visible = true
		%MovesMenu.get_child(0).grab_focus()
	elif state == State.ENEMY_ATTACK:
		# TODO: Randomly select enemy move / implement smart AI
		_on_move_selected(0, %Player)
	elif state == State.ATTACKING_INFO:
		_render_hp()
		%BattleStatus.visible = true
		%BattleStatus.text = label_text
		%ContinueButton.visible = true
		%ContinueButton.grab_focus()
	elif state == State.GAME_END:
		%BattleStatus.visible = true
		%ContinueButton.grab_focus()

func _init_battle_participants():
	for enemy in %Enemies.get_children():
		enemy.speed = 20
		enemy.is_player = false
		battle_participants.append(enemy)
	battle_participants.append(%Player)
	battle_participants.sort_custom(func(a, b): return a.speed - b.speed)

func _init_moves():
	for i in %Player.moves.size():
		%MovesMenu.get_child(i).text = %Player.moves[i].move_name
		%MovesMenu.get_child(i).focus_entered.connect(func(): _display_pp_info(%Player.moves[i]))

func _on_move_pressed(index: int) -> void:
	_on_move_selected(index, %Enemy)
	
func _on_move_selected(index: int, target: BattleParticipant) -> void:
	var results = battle_participants[turn_order_index].use_move(index, target)
	var used_move_name = results[0].move_name
	var damage = results[1]
	var message = "%s used %s on %s for %d damage!" % [battle_participants[turn_order_index].character_name, used_move_name, target.character_name, damage]
	_update_state(State.ATTACKING_INFO, message)

func _render_hp() -> void:
	%EnemyPanel.text = "Enemy " + str(%Enemy.hp) + " / " + str(%Enemy.max_hp)
	%PlayerPanel.text = "Player " + str(%Player.hp) + " / " + str(%Player.max_hp)

func _on_continue_button_pressed() -> void:
	if state == State.ATTACKING_INFO:
		_increment_turn_order()
	elif state == State.GAME_END:
		get_tree().quit()
		
func _increment_turn_order():
	turn_order_index += 1
	if turn_order_index == battle_participants.size():
		turn_order_index = 0
		turn += 1
	if battle_participants[turn_order_index].is_player:
		_update_state(State.SELECTING_ACTION, "What will %s do?" % %Player.character_name)
	else:
		_update_state(State.ENEMY_ATTACK)

func _on_attack_pressed() -> void:
	if state == State.SELECTING_ACTION:
		_update_state(State.SELECTING_ATTACK)

func _display_pp_info(move: Move) -> void:
	%PPInfo.text = "%d / %d" % [move.pp, move.max_pp]
	%TypeInfo.text = Move.Types.keys()[move.type]

func _render_moves():
	for i in %Player.moves.size():
		var move = %Player.moves[i]
		if move.pp <= 0:
			%MovesMenu.get_child(i).disabled = true
		else:
			%MovesMenu.get_child(i).disabled = false

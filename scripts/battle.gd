extends Node2D
var moves_list = MovesList.new()
var turn: int = 0
var turn_order_index: int = 0
var battle_participants = []

enum State {SELECTING_ACTION, SELECTING_ATTACK, PLAYER_ATTACK_INFO, ENEMY_ATTACK, ENEMY_ATTACK_INFO}
var state: State = State.SELECTING_ACTION

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_battle_participants()
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
		%MovesMenu.visible = false
	elif old_state == State.PLAYER_ATTACK_INFO || old_state == State.ENEMY_ATTACK_INFO:
		%ContinueButton.visible = false
		%BattleStatus.visible = false
		_render_hp()

	if state == State.SELECTING_ACTION:
		%PlayerPrompt.visible = true
		#%PlayerPrompt.size.x = 255
		%PlayerPrompt.text = label_text
		%Action.visible = true
		%Action.get_child(0).grab_focus()
	elif state == State.SELECTING_ATTACK:
		%MovesMenu.visible = true
		%MovesMenu.get_child(0).grab_focus()
	elif state == State.ENEMY_ATTACK:
		var results = %Enemy.use_move(0, %Player)
		var used_move_name = results[0].move_name
		var damage = results[1]
		var message = "%s used %s on %s for %d damage!" % [%Enemy.character_name, used_move_name, %Player.character_name, damage]
		_update_state(State.ENEMY_ATTACK_INFO, message)
	elif state == State.PLAYER_ATTACK_INFO:
		%BattleStatus.visible = true
		%BattleStatus.text = label_text
		%ContinueButton.visible = true
		%ContinueButton.grab_focus()
	elif state == State.ENEMY_ATTACK_INFO:
		%BattleStatus.visible = true
		%BattleStatus.text = label_text
		%ContinueButton.visible = true
		%ContinueButton.grab_focus()

func _init_battle_participants():
	for enemy in %Enemies.get_children():
		enemy.speed = 20
		enemy.is_player = false
		battle_participants.append(enemy)
	battle_participants.append(%Player)
	battle_participants.sort_custom(func(a, b): return a.speed - b.speed)

func _on_move_pressed(index: int) -> void:
	var results = %Player.use_move(index, %Enemy)
	var used_move_name = results[0].move_name
	var damage = results[1]
	var message = "%s used %s on %s for %d damage!" % [%Player.character_name, used_move_name, %Enemy.character_name, damage]
	_update_state(State.PLAYER_ATTACK_INFO, message)

func _render_hp() -> void:
	%EnemyPanel.text = "Enemy " + str(%Enemy.hp) + " / " + str(%Enemy.max_hp)
	%PlayerPanel.text = "Player " + str(%Player.hp) + " / " + str(%Player.max_hp)

func _on_info_button_pressed() -> void:
	if state == State.PLAYER_ATTACK_INFO:
		_update_state(State.ENEMY_ATTACK)
	elif state == State.ENEMY_ATTACK_INFO:
		_update_state(State.SELECTING_ACTION, "What will %s do?" % %Player.character_name)

func _on_attack_pressed() -> void:
	if state == State.SELECTING_ACTION:
		_update_state(State.SELECTING_ATTACK)

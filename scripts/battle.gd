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
		_update_state(State.SELECTING_ACTION)
	else:
		_update_state(State.ENEMY_ATTACK)

func _update_state(new_state: State):
	var old_state = state
	state = new_state

	%StateDisplay.text = State.keys()[state]

	if old_state == State.SELECTING_ACTION:
		%Action.visible = false
	elif old_state == State.SELECTING_ATTACK:
		%MovesMenu.visible = false
	elif old_state == State.PLAYER_ATTACK_INFO || old_state == State.ENEMY_ATTACK_INFO:
		%ContinueButton.visible = false
		_render_hp()

	if state == State.SELECTING_ACTION:
		%Status.size.x = 255
		%Status.text = "What will PLAYER do?"
		%Action.visible = true
		%Action.get_child(0).grab_focus()
	elif state == State.SELECTING_ATTACK:
		%MovesMenu.visible = true
		%MovesMenu.get_child(0).grab_focus()
	elif state == State.ENEMY_ATTACK:
		%Enemy.use_move(0, %Player)
		_update_state(State.ENEMY_ATTACK_INFO)
	elif state == State.PLAYER_ATTACK_INFO:
		%Status.text = "Player Attacked Enemy"
		%ContinueButton.visible = true
		%ContinueButton.grab_focus()
	elif state == State.ENEMY_ATTACK_INFO:
		%Status.text = "Enemy Attacked Player"
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
	%Player.use_move(index, %Enemy)
	_update_state(State.PLAYER_ATTACK_INFO)

func _render_hp() -> void:
	%EnemyPanel.text = "Enemy " + str(%Enemy.hp) + " / " + str(%Enemy.max_hp)
	%PlayerPanel.text = "Player " + str(%Player.hp) + " / " + str(%Player.max_hp)

func _on_info_button_pressed() -> void:
	if state == State.PLAYER_ATTACK_INFO:
		_update_state(State.ENEMY_ATTACK)
	elif state == State.ENEMY_ATTACK_INFO:
		_update_state(State.SELECTING_ACTION)

func _on_attack_pressed() -> void:
	if state == State.SELECTING_ACTION:
		_update_state(State.SELECTING_ATTACK)

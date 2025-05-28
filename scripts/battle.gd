class_name Battle
extends Node2D

const STATE_ATTACKING_INFO := "ATTACKING_INFO"
const STATE_INCREMENT_TURN := "INCREMENT_TURN"
const STATE_SELECTING_ACTION := "SELECTING_ACTION"
const STATE_ENEMY_ATTACK := "ENEMY_ATTACK"
const STATE_GAME_END := "GAME_END"
const STATE_SELECTING_ATTACK := "SELECTING_ATTACK"
const STATE_ATTACK := "ATTACK"

var turn: int = 0
var turn_order_index: int = -1

var battle_participants = []
var enemies: Array = []

var current_state: BaseState

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Called once to seed the random number generator
	randomize()
	_init_states()
	_init_battle_participants()
	render_hp()
	transition_state_to(STATE_INCREMENT_TURN)

func _init_states():
	# Initialize all states
	for child in %BattleStateMachine.get_children():
		if child is BaseState:
			child.battle = self

func _init_battle_participants():
	battle_participants.clear()
	battle_participants.append(%Player)
	enemies.clear()
	for enemy_node in %Enemies.get_children():
		enemy_node.is_player = false
		battle_participants.append(enemy_node)
		enemies.append(enemy_node)

	battle_participants.sort_custom(_sort_participants_by_speed)

func _sort_participants_by_speed(a, b) -> bool:
	if a.speed == b.speed:
		return randf() < 0.5  # More readable than randi() % 2
	return a.speed > b.speed

func transition_state_to(state_name: String, messages: Array = []):
	if not %BattleStateMachine.has_node(state_name):
		push_error("Invalid state: " + state_name)
		return

	if current_state:
		current_state.exit()

	print("Entering state: ", state_name)
	%StateDisplay.text = state_name

	current_state = %BattleStateMachine.get_node(state_name)
	current_state.enter(messages)

func render_hp() -> void:
	if enemies.size() > 0:
		%EnemyPanel.text = "Enemy " + str(enemies[0].hp) + " / " + str(enemies[0].max_hp)
	else:
		%EnemyPanel.text = "Enemy ?"
	%PlayerPanel.text = "Player " + str(%Player.hp) + " / " + str(%Player.max_hp)

func _on_continue_button_pressed() -> void:
	current_state.handle_continue()

func get_current_attacker():
	return battle_participants[turn_order_index]

class_name Battle
extends Node2D
var turn: int = 0
var turn_order_index: int = -1

var battle_participants = []
var enemy: BattleParticipant

var states: Dictionary = {}
var current_state: BaseState

enum State {
	ATTACKING_INFO,
	INCREMENT_TURN,
	SELECTING_ACTION,
	ENEMY_ATTACK,
	GAME_END,
	SELECTING_ATTACK,
	ATTACK
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Called once to seed the random number generator
	randomize()
	_init_states()
	_init_battle_participants()
	render_hp()

	transition_state_to(State.INCREMENT_TURN)

func _init_states():
	# Initialize all states
	for child in %BattleStateMachine.get_children():
		if child is BaseState:
			states[child.name] = child
			child.battle = self

func _init_battle_participants():
	battle_participants.clear()
	battle_participants.append(%Player)
	for enemy_node in %Enemies.get_children():
		enemy_node.is_player = false
		battle_participants.append(enemy_node)
		enemy = enemy_node


	battle_participants.sort_custom(_sort_participants_by_speed)

func _sort_participants_by_speed(a, b) -> bool:
	if a.speed == b.speed:
		return randf() < 0.5  # More readable than randi() % 2
	return a.speed > b.speed

func transition_state_to(state: State, messages: Array = []):
	var state_name = State.keys()[state]
	if not states.has(state_name):
		push_error("Invalid state: " + state_name)
		return

	if current_state:
		current_state.exit()

	print("entering state: ", state_name)
	%StateDisplay.text = state_name

	current_state = states[state_name]
	current_state.enter(messages)

func render_hp() -> void:
	%EnemyPanel.text = "Enemy " + str(%Enemy.hp) + " / " + str(%Enemy.max_hp)
	%PlayerPanel.text = "Player " + str(%Player.hp) + " / " + str(%Player.max_hp)

func _on_continue_button_pressed() -> void:
	current_state.handle_continue()

func get_current_attacker():
	return battle_participants[turn_order_index]

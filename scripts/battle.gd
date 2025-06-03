class_name Battle
extends Node2D

const STATE_INFO := "INFO"
const STATE_INCREMENT_TURN := "INCREMENT_TURN"
const STATE_SELECTING_ACTION := "SELECTING_ACTION"
const STATE_ENEMY_ATTACK := "ENEMY_ATTACK"
const STATE_GAME_END := "GAME_END"
const STATE_SELECTING_ATTACK := "SELECTING_ATTACK"
const STATE_ATTACK := "ATTACK"
const STATE_ENACT_STATUSES := "ENACT_STATUSES"
const STATE_SELECTING_ITEM := "SELECTING_ITEM"
const NONE := "NONE"

var turn: int = 0
var turn_order_index: int = -1

var active_monsters = []
var current_enemy: Monster

var current_state: BaseState
var previous_state

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Called once to seed the random number generator
	randomize()
	_init_states()
	_init_battle_participants()

func _init_states():
	# Initialize all states
	for child in %BattleStateMachine.get_children():
		if child is BaseState:
			child.battle = self

func _init_battle_participants():
	active_monsters.clear()
	active_monsters.append(%Player.selected_monster)
	for monster in %Enemy.monsters:
		# TODO: Later this will need to change. Only 2 Monsters should be in active_monsters at a time. 
		current_enemy = monster
		active_monsters.append(monster)

	active_monsters.sort_custom(_sort_participants_by_speed)
	render_hp()
	transition_state_to(STATE_INCREMENT_TURN)

func _sort_participants_by_speed(a: Monster, b: Monster) -> bool:
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

	previous_state = current_state
	current_state = %BattleStateMachine.get_node(state_name)
	current_state.enter(messages)

func render_hp() -> void:
	if current_enemy:
		%EnemyPanel.text = "%s %d / %d" % [current_enemy.character_name, current_enemy.hp, current_enemy.max_hp]
	else:
		%EnemyPanel.text = "Enemy ?"
	%PlayerPanel.text = "%s %d / %d" % [%Player.selected_monster.character_name, %Player.selected_monster.hp, %Player.selected_monster.max_hp]

	%EnemyPanel.text += "\n %s" % MovesList.Type.keys()[%Enemy.selected_monster.type]
	%PlayerPanel.text += "\n %s" % MovesList.Type.keys()[$Player.selected_monster.type]

func _on_continue_button_pressed() -> void:
	current_state.handle_continue()

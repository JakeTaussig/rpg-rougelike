extends Node2D
class_name BattleParticipant

@export var character_name: String = "Player"
@export var max_hp: int = 100:
	set(new_health):
		max_hp = max(1, new_health)
@export var hp: int = 100:
	set(new_health):
		hp = max(0, new_health)
@export var atk: int = 20:
	set(new_atk):
		atk = max(1, new_atk)
@export var sp_atk: int = 20:
	set(new_sp_atk):
		sp_atk = max(1, new_sp_atk)
@export var def: int = 20:
	set(new_def):
		def = max(1, new_def)
@export var sp_def: int = 20:
	set(new_sp_def):
		sp_def = max(1, new_sp_def)
@export var speed: int = 30:
	set(new_speed):
		speed = max(1, new_speed)
@export var luck: int = 10:
	set(new_luck):
		luck = max(1, new_luck)
var is_player = true
var moves: Array[Move] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _init():
	moves = GameManager.moves_list
	
func use_move(index: int, target: BattleParticipant) -> Array:
	var move = moves[index]
	var attack_hit: bool = _does_attack_hit(move.acc)
	if attack_hit:
		if move.category == Move.MoveCategory.ATK:
			var damage = max(1, _attack(move, target, 1))
			return [move, damage]
		elif move.category == Move.MoveCategory.SP_ATK:
			var damage = max(1, _attack(move, target, 0))
			return [move, damage]
	else:
		return [move, 0]
	# Placeholder
	return []
	
func _does_attack_hit(accuracy: int):
	accuracy = clamp(accuracy, 0, 100)
	
	# Generates a number between 1 and 100
	var roll = randi() % 100 + 1
	return roll <= accuracy
	
	
func increment_health(value: int) -> void:
	hp += value
	
func _attack(move: Move, target: BattleParticipant, is_physical: bool) -> int:
	var power = move.base_power
	var damage = 0
	if is_physical:
		power = power * atk
		damage = power / target.def
	else:
		power = power * sp_atk
		damage = power / target.sp_def
	target.hp -= damage
	return damage

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

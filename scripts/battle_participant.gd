extends Node2D
class_name BattleParticipant

enum AI_TYPE { RANDOM, AGGRESSIVE, HIGH_EV }
@export var ai_type: AI_TYPE = AI_TYPE.HIGH_EV

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
	# DEBUG: for now each battle participant's moves are set to copy the global moves_list
	for move in GameManager.moves_list:
		moves.append(move.copy())

	
func use_move(index: int, target: BattleParticipant) -> Array:
	var move = moves[index]
	move.pp -= 1
	var attack_hit: bool = _does_attack_hit(move.acc)
	if attack_hit:
		var damage = 0
		if move.category == Move.MoveCategory.ATK:
			damage = max(1, _attack(move, target, 1))
			return [move, damage]
		elif move.category == Move.MoveCategory.SP_ATK:
			damage = max(1, _attack(move, target, 0))
			return [move, damage]
	return [move, 0]

	
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

# Only called by enemy
func select_move() -> int:
	var available_moves = []
	for i in moves.size():
		if moves[i].pp > 0:
			available_moves.append(i)
	if available_moves.is_empty():
		return -1

	match ai_type:
		AI_TYPE.RANDOM:
			return available_moves.pick_random()
		AI_TYPE.AGGRESSIVE:
			var best_move = available_moves[0]
			var max_power = 0
			for idx in available_moves:
				if moves[idx].base_power > max_power:
					max_power = moves[idx].base_power
					best_move = idx
			return best_move
		AI_TYPE.HIGH_EV:
			var best_move = available_moves[0]
			var max_ev = 0
			for idx in available_moves:
				var move = moves[idx]
				var move_ev = move.base_power * move.acc
				if move_ev > max_ev:
					max_ev = move_ev
					best_move = idx
			return best_move
	return available_moves.pick_random()

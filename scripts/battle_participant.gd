extends Node2D
class_name BattleParticipant

@export var max_hp: int = 100
@export var hp: int = 100
@export var atk: int = 20
@export var sp_atk: int = 20
@export var def: int = 20
@export var sp_def: int = 20
@export var speed: int = 30
@export var luck: int = 10
var is_player = true
var moves: Array[Move] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _init():
	moves = GameManager.moves_list
	
func use_move(index: int, target: BattleParticipant) -> void:
	var move = moves[index]
	if move.category == Move.MoveCategory.ATK:
		_attack(move, target, 1)
	elif move.category == Move.MoveCategory.SP_ATK:
		_attack(move, target, 0)
	
func increment_health(value: int) -> void:
	hp += value
	
func _attack(move: Move, target: BattleParticipant, is_physical: bool):
	var power = move.base_power
	var damage = 0
	if is_physical:
		power = power * atk
		damage = power / target.def
	else:
		power = power * sp_atk
		damage = power / target.sp_def
	target.hp -= damage

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

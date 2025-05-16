extends Node2D

@export var max_hp: int = 100
@export var hp: int = 100
@export var atk: int = 20
@export var sp_atk: int = 20
@export var def: int = 20
@export var sp_def: int = 20
@export var speed: int = 30
@export var luck: int = 10
var is_player = true
var moves_dict: Array[String] = ["Bubblebeam", "Flamethrower", "Razor_leaf", "Fire_punch"]
var moves: Array[move] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for dict_move in moves_dict:
		var _move:move = move.new()
		moves.append(_move)
	pass
	
func use_move(index: int, target_self: bool) -> void:
	var move = moves[index]
	
func increment_health(value: int) -> void:
	hp += value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

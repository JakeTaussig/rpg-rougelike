class_name Monster
extends Resource

@export var character_name: String = "Monster"
@export var texture: CompressedTexture2D = preload("res://assets/sprites/characters/oddesque.png")

@export var max_hp: int = 100:
	set(new_max_hp):
		max_hp = max(1, new_max_hp)
		hp = min(hp, max_hp) # Clamp down hp if max_hp is decreased. 
@export var hp: int = 100:
	set(new_hp):
		hp = clamp(new_hp, 0, max_hp) # hp can never exceed max_hp
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

@export var type: MovesList.Type

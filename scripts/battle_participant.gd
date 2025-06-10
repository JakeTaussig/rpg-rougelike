@tool
extends Sprite2D
class_name BattleParticipant

@export var monsters: Array[Monster] = []:
	set(_monsters):
		monsters = _monsters
		if len(monsters) > 0:
			selected_monster = monsters[0]

var selected_monster: Monster:
	set(new_monster):
		selected_monster = new_monster
		_render_battler()

var is_player = true:
	set(_is_player):
		is_player = _is_player
		selected_monster.is_player = _is_player
		_render_battler()

# TODO: Move sprite stuff to monster.gd
func _render_battler():
	texture = selected_monster.texture
	flip_h = is_player

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		# TODO: Make it so you can select moves in the editor for Monsters, and make it so they can be randomly selected. 
		for move in GameManager.moves_list.moves.slice(0, 4):
			selected_monster.moves.append(move.copy())
			
func is_defeated() -> bool:
	return selected_monster.hp <= 0 && monsters.size() == 1

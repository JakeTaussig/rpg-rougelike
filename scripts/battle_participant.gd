@tool
extends Sprite2D
class_name BattleParticipant

@export var items: Array[Item] = []

@export var monsters: Array[Monster] = []:
	set(_monsters):
		monsters = _monsters
		if len(monsters) > 0:
			selected_monster = monsters[0]

		_setup_monsters()


func _setup_monsters():
	for i in monsters.size():
		monsters[i] = monsters[i].duplicate(true)
	if monsters.size() > 0:
		selected_monster = monsters[0]


var selected_monster: Monster:
	set(new_monster):
		selected_monster = new_monster
		render_battler()

var is_player = true:
	set(_is_player):
		is_player = _is_player
		selected_monster.is_player = _is_player
		render_battler()


func render_battler():
	texture = selected_monster.texture
	flip_h = is_player
	$StatusEmitter.status_effect = selected_monster.status_effect


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		# TODO: Make it so you can select moves in the editor for Monsters, and make it so they can be randomly selected.
		for monster in monsters:
			if monster.moves.is_empty():
				for move in GameManager.moves_list.moves.slice(0, 4):
					monster.moves.append(move.copy())

		call_deferred("_init_items")


func _init_items() -> void:
	# TODO: dummy implementation -- give each participant 5 of each item
	for item in GameManager.items_list.items:
		var player_item = item.copy()
		player_item.qty = 5
		items.append(player_item)


func is_defeated() -> bool:
	for monster in monsters:
		if monster.hp > 0:
			return false
	return true


func swap_dead_monster():
	if selected_monster.hp <= 0:
		monsters.remove_at(0)
		if monsters.size() == 0:
			return
		selected_monster = monsters[0]

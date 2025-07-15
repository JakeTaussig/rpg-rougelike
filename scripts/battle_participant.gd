@tool
extends Sprite2D
class_name BattleParticipant

@export var items: Array[Item] = []

@export var monsters: Array[Monster] = []:
	set(_monsters):
		monsters = []
		for monster in _monsters:
			monsters.append(monster.duplicate(true))
		if monsters.size() > 0:
			selected_monster = monsters[0]

signal trinkets_updated

var trinkets: Array[Trinket] = []


func emit_trinkets_updated_signal():
	trinkets_updated.emit()


# called at the start of battle -- applies trinket effects to the player's monster
func apply_trinkets():
	for trinket in trinkets:
		trinket.strategy.ApplyEffect(selected_monster)


func setup_player(_monster: Monster):
	monsters = [_monster]
	position.x = 64
	position.y = 72


var selected_monster: Monster:
	set(new_monster):
		selected_monster = new_monster
		render_battler()

var is_player = true:
	set(_is_player):
		is_player = _is_player
		render_battler()


func render_battler():
	texture = selected_monster.texture
	flip_h = is_player
	$StatusEmitter.status_effect = selected_monster.status_effect


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	if not Engine.is_editor_hint():
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

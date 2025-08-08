@tool
extends Sprite2D
class_name BattleParticipant

@export var monsters: Array[Monster] = []:
	set(_monsters):
		monsters = []
		for monster in _monsters:
			monsters.append(monster.duplicate(true))
		if monsters.size() > 0:
			selected_monster = monsters[0]


var prana: int = 0


func setup_player(_monster: Monster):
	monsters = [_monster]
	position.x = 64
	position.y = 72


var selected_monster: Monster:
	set(new_monster):
		selected_monster = new_monster
		selected_monster.connect("attack_used", play_attack_animation)
		render_battler()

func play_death_animation():
	var ap: AnimationPlayer = $AnimationPlayer
	var speed = 1
	var from_end = false
	ap.play("horiz_slice", -1, speed, from_end)

	await get_tree().create_timer(speed).timeout
	hide()
	ap.play("RESET")

func play_attack_animation():
	var ap: AnimationPlayer = $AnimationPlayer

	var speed = 1
	var from_end = false

	# reverse the animation for the player sprite
	if is_player:
		speed = -1
		from_end = true

	ap.play("attack_shake", -1, speed, from_end)

# This is used as a fallback to apply new Trinkets and remove secondary move effects after battle.
var selected_monster_backup: Monster
	

var is_player = true:
	set(_is_player):
		is_player = _is_player
		render_battler()


func render_battler():
	texture = selected_monster.texture
	flip_h = is_player
	$StatusEmitter.status_effect = selected_monster.status_effect


func is_defeated() -> bool:
	if is_player:
		if selected_monster.hp > 0:
			return false
	else:
		for monster in monsters:
			if monster.hp > 0:
				return false

	return true


func swap_dead_monster():
	if selected_monster.hp <= 0:
		selected_monster.status_effect = MovesList.StatusEffect.NONE
		monsters.remove_at(0)
		if monsters.size() == 0:
			return
		selected_monster = monsters[0]
		show()

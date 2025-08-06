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

func play_attack_animation():
	var ap: AnimationPlayer = $AnimationPlayer
	ap.play("attack_shake")

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

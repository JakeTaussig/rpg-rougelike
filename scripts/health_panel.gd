extends Control
class_name HealthPanel

@export var show_hp_numbers = true


func _ready():
	if !show_hp_numbers:
		%HPNumber.visible = false
		%BottomHealthBackdrop.visible = false


func render_hp(monster: Monster):
	var damage = %HPBar.value - monster.hp
	%NameLabel.text = "%s" % monster.character_name
	%HPBar.max_value = monster.max_hp
	%TypeLabel.text = "%s" % _set_bbcode_color(MovesList.Type.find_key(monster.type), MovesList.type_to_color(monster.type))
	if not monster.status_effect == MovesList.StatusEffect.NONE:
		%StatusLabelPanel.visible = true
		%StatusLabel.text = "%s" % _set_bbcode_color(MovesList.type_abbreviation(monster.status_effect), MovesList.status_effect_to_color(monster.status_effect))
	else:
		%StatusLabelPanel.visible = false
	var prior_hp = %HPBar.value
	while damage > 0 and prior_hp > 0:
		await get_tree().create_timer(0.01).timeout
		if damage >= 2:
			prior_hp -= 2
			damage -= 2
		else:
			prior_hp -= damage
			damage = 0
		%HPBar.value = prior_hp
		_set_hp_bar_color()
		%HPNumber.text = "%d / %d" % [prior_hp, monster.max_hp]
		await get_tree().process_frame

	# Set again here, for cases in which we need to render and no damage was done.
	%HPBar.value = monster.hp
	_set_hp_bar_color()
	%HPNumber.text = "%d / %d" % [monster.hp, monster.max_hp]


func _set_hp_bar_color():
	var hp_bar: ProgressBar = %HPBar

	if hp_bar.value / hp_bar.max_value > 0.5:
		hp_bar.add_theme_stylebox_override("fill", load("res://assets/styles/hp_foreground_green_sbf.tres"))
	elif hp_bar.value / hp_bar.max_value > 0.25:
		hp_bar.add_theme_stylebox_override("fill", load("res://assets/styles/hp_foreground_yellow_sbf.tres"))
	else:
		hp_bar.add_theme_stylebox_override("fill", load("res://assets/styles/hp_foreground_red_sbf.tres"))


static func _set_bbcode_color(input_string: String, color: Color):
	return "[color=%s]%s[/color]" % [color.to_html(), input_string]

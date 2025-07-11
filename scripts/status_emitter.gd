extends CPUParticles2D

@export var status_effect: MovesList.StatusEffect = MovesList.StatusEffect.NONE:
	set(_status):
		status_effect = _status
		_render_status()


func _init():
	set_material(material.duplicate())


func _render_status():
	var shader_material: ShaderMaterial = material
	position = Vector2(0, 0)
	match status_effect:
		MovesList.StatusEffect.DELUSION:
			emitting = true
			gravity = Vector2(0, 250)
			position.y -= 8
			texture = load("res://assets/sprites/status_effects/water.png")
		MovesList.StatusEffect.POISON:
			emitting = true
			gravity = Vector2(0, -250)
			texture = load("res://assets/sprites/status_effects/poison.png")
		MovesList.StatusEffect.CRIPPLE:
			emitting = true
			gravity = Vector2(0, 250)
			position.y -= 8
			texture = load("res://assets/sprites/status_effects/cripple.png")
		MovesList.StatusEffect.BURN:
			emitting = true
			gravity = Vector2(0, -250)
			texture = load("res://assets/sprites/status_effects/burn.png")
		MovesList.StatusEffect.CONSUME:
			emitting = true
			gravity = Vector2(0, -250)
			texture = load("res://assets/sprites/status_effects/consume.png")
		MovesList.StatusEffect.PARALYZE:
			emitting = true
			gravity = Vector2(0, -250)
			texture = load("res://assets/sprites/status_effects/paralyze.png")
		MovesList.StatusEffect.BLIND:
			emitting = true
			gravity = Vector2(0, -250)
			texture = load("res://assets/sprites/status_effects/blind.png")
		_:
			texture = null
			emitting = false

	var outline_color = MovesList.status_effect_to_color(status_effect)

	# set outline for particles
	shader_material.set_shader_parameter("color", outline_color)
	shader_material.set_shader_parameter("width", 1.0)
	shader_material.set_shader_parameter("add_margins", true)
	shader_material.set_shader_parameter("inside", false)

	# set outline for monster
	var parent = get_parent()
	if not parent.material:
		parent.material = load("res://assets/shaders/outline-material.tres").duplicate()
	parent.material.set_shader_parameter("color", outline_color)
	parent.material.set_shader_parameter("add_margins", false)
	parent.material.set_shader_parameter("width", 2.0)
	parent.material.set_shader_parameter("pattern", 1)

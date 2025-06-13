extends CPUParticles2D

@export var status_effect: MovesList.StatusEffect = MovesList.StatusEffect.NONE:
	set(_status):
		status_effect = _status
		_render_status()

func _init():
	set_material(material.duplicate())

func _render_status():
	var shader_material: ShaderMaterial = material
	var outline_color: Color = Color(0.0, 0.0, 0.0, 0.0)
	position = Vector2(0, 0)
	match status_effect:
		MovesList.StatusEffect.WHIRLPOOL:
			emitting = true
			gravity = Vector2(0, 250)
			position.y -= 8
			outline_color = Color(0.0, 0.6, 0.859, 1.0)
			texture = load("res://assets/sprites/status_effects/water.png")
		MovesList.StatusEffect.POISON:
			emitting = true
			gravity = Vector2(0, -250)
			outline_color = Color(0.408, 0.22, 0.424, 1.0)
			texture = load("res://assets/sprites/status_effects/poison.png")
		MovesList.StatusEffect.CRIPPLE:
			emitting = true
			gravity = Vector2(0, 250)
			position.y -= 8
			outline_color = Color(1.0, 0.0, 0.267, 1.0)
			texture = load("res://assets/sprites/status_effects/cripple.png")
		MovesList.StatusEffect.BURN:
			emitting = true
			gravity = Vector2(0, -250)
			outline_color = Color(0.894, 0.231, 0.267, 1.0)
			texture = load("res://assets/sprites/status_effects/burn.png")
		MovesList.StatusEffect.CONSUME:
			emitting = true
			gravity = Vector2(0, -250)
			outline_color = Color(0.094, 0.078, 0.145, 1.0)
			texture = load("res://assets/sprites/status_effects/consume.png")
		MovesList.StatusEffect.PARALYZE:
			emitting = true
			gravity = Vector2(0, -250)
			outline_color = Color(0.243, 0.153, 0.192, 1.0)
			texture = load("res://assets/sprites/status_effects/paralyze.png")
		MovesList.StatusEffect.BLIND:
			emitting = true
			gravity = Vector2(0, -250)
			outline_color = Color(0.545, 0.608, 0.706, 1.0)
			texture = load("res://assets/sprites/status_effects/blind.png")
		_:
			texture = null
			emitting = false

	shader_material.set_shader_parameter("color", outline_color)
	shader_material.set_shader_parameter("width", 1.0)
	shader_material.set_shader_parameter("add_margins", true)
	shader_material.set_shader_parameter("inside", false)

	var parent = get_parent()
	if not parent.material:
		parent.material = load("res://assets/shaders/outline-material.tres").duplicate()
	parent.material.set_shader_parameter("color", outline_color)
	parent.material.set_shader_parameter("add_margins", false)
	parent.material.set_shader_parameter("width", 2.0)
	parent.material.set_shader_parameter("pattern", 1)

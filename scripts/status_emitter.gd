@tool
extends CPUParticles2D

@export var status_effect: MovesList.StatusEffect = MovesList.StatusEffect.NONE:
	set(_status):
		status_effect = _status
		_render_status()

func _render_status():
	match status_effect:
		MovesList.StatusEffect.WHIRLPOOL:
			emitting = true
			gravity = Vector2(0, 250)
			texture = load("res://assets/sprites/status_effects/water.png")
		MovesList.StatusEffect.POISON:
			emitting = true
			gravity = Vector2(0, -250)
			texture = load("res://assets/sprites/status_effects/poison.png")
		MovesList.StatusEffect.CRIPPLE:
			emitting = true
			gravity = Vector2(0, 250)
			texture = load("res://assets/sprites/status_effects/cripple.png")
		MovesList.StatusEffect.BURN:
			emitting = true
			gravity = Vector2(0, -250)
			texture = load("res://assets/sprites/status_effects/burn.png")
			pass
		MovesList.StatusEffect.CONSUME:
			emitting = true
			gravity = Vector2(0, -250)
			texture = load("res://assets/sprites/status_effects/consume.png")
			pass
		MovesList.StatusEffect.PARALYZE:
			emitting = true
			gravity = Vector2(0, -250)
			texture = load("res://assets/sprites/status_effects/paralyze.png")
		MovesList.StatusEffect.BLIND:
			emitting = true
			gravity = Vector2(0, -250)
			texture = load("res://assets/sprites/status_effects/blind.png")
			pass
		_:
			texture = null
			emitting = false

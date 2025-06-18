extends ColorRect


func fade_out(duration := 2.0) -> void:
	modulate.a = 0.0
	show()
	var tween = create_tween()
	await tween.tween_property(self, "modulate:a", 1.0, duration).finished


func fade_in(duration := 2.0) -> void:
	modulate.a = 1.0
	show()
	var tween = create_tween()
	await tween.tween_property(self, "modulate:a", 0.0, duration).finished
	hide()

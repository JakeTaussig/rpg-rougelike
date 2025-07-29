extends Node2D


func _init():
	for type in MovesList.Type.values():
		var key = MovesList.Type.find_key(type)

		var text = "%s" % HealthPanel._set_bbcode_color(key, MovesList.type_to_color(type).to_html())
		_create_label(text, (type + 1) * 15, 0)

	for StatusEffect in MovesList.StatusEffect.values():
		var key = MovesList.StatusEffect.find_key(StatusEffect)

		var text = "%s" % HealthPanel._set_bbcode_color(key, MovesList.status_effect_to_color(StatusEffect).to_html())
		_create_label(text, StatusEffect * 15, 96)


func _create_label(text, y_offset, x_offset):
	var label = RichTextLabel.new()

	print(y_offset)

	label.position.y = y_offset
	label.position.x = x_offset
	label.size.x = 100
	label.size.y = 16
	label.bbcode_enabled = true
	label.fit_content = true

	label.text = text

	add_child(label)

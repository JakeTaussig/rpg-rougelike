extends Control
class_name Shop

signal shop_ended

# The shop will contain this many trinkets
const N_TRINKETS = 3

var trinkets: Array[Trinket] = []

func setup():
	_roll_trinkets()
	_init_trinket_menu_buttons()
	_render_trinkets()
	_render_player_money()


func _init_trinket_menu_buttons():
	for i in range(N_TRINKETS):
		var trinket_entry: HBoxContainer = %TrinketContainer.get_child(i + 1)
		var trinket_button: Button = trinket_entry.get_node("TrinketName")
		var trinket = trinkets[i]
		trinket_button.connect("mouse_entered", func(): _on_trinket_hover(trinket))
		trinket_button.connect("mouse_exited", _on_trinket_hover_exit)
		trinket_button.pressed.connect(func(): _on_trinket_button_pressed(i))

func _roll_trinkets():
	while trinkets.size() < N_TRINKETS:
		var trinket = GameManager.trinkets_list.trinkets.pick_random()

		# TODO: validate that the player does not have the trinket before adding it to the shop
		# TODO: consider preventing trinkets from appearing in the shop more than once
		# TODO: need a fallback if less than N_TRINKETS trinkets are available
		if !trinkets.has(trinket):
			trinkets.append(trinket)

func _render_trinkets():
	for i in range(N_TRINKETS):
		var trinket_entry: HBoxContainer = %TrinketContainer.get_child(i + 1)
		trinket_entry.get_node("TrinketName").text = trinkets[i].trinket_name
		trinket_entry.get_node("TrinketIcon").texture = trinkets[i].icon


func _render_player_money():
	%Money.text = "¶ %d" % GameManager.player.money


func _on_trinket_hover(trinket: Trinket):
	%TrinketInfo.text = trinket.description
	%TrinketIconEnlarged.texture = trinket.icon
	%TrinketName.text = trinket.trinket_name
	%TrinketInfoContainer.show()
	%TrinketNameAndCost.show()

func _on_trinket_hover_exit():
	%TrinketInfoContainer.hide()
	%TrinketNameAndCost.hide()

func _on_trinket_button_pressed(trinket_index: int):
	var trinket: Trinket = trinkets[trinket_index]
	var trinket_button: Button = %TrinketContainer.get_child(trinket_index + 1).get_node("TrinketName")
	var trinket_cost_label: RichTextLabel = %TrinketContainer.get_child(trinket_index + 1).get_node("TrinketCost")
	var trinket_icon: TextureRect = %TrinketContainer.get_child(trinket_index + 1).get_node("TrinketIcon")

	# TODO: introduce varying trinket costs
	var trinket_cost = 100

	if GameManager.player.money < trinket_cost:
		return

	trinket_button.disabled = true
	trinket_cost_label.text = "[s]%s[/s]" % trinket_cost_label.text
	trinket_cost_label.add_theme_color_override("default_color", Color(0.545, 0.608, 0.706, 1.0))
	trinket_icon.material = load("res://assets/shaders/grayscale-material.tres")

	GameManager.player.trinkets.append(trinket)

	GameManager.player.money -= trinket_cost
	_render_player_money()


func _on_exit_button_pressed() -> void:
	shop_ended.emit()

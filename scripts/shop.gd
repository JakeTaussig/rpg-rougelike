extends Control

# The shop will contain this many trinkets
const N_TRINKETS = 3

var trinkets: Array[Trinket] = []

func _ready():
	_roll_trinkets()
	_init_trinket_menu_buttons()
	_render_trinkets()


func _init_trinket_menu_buttons():
	for i in range(N_TRINKETS):
		var trinket_entry: HBoxContainer = %TrinketContainer.get_child(i + 1)
		var trinket_button: Button = trinket_entry.get_node("TrinketName")
		var trinket = trinkets[i]
		trinket_button.connect("mouse_entered", func(): _on_trinket_hover(trinket))
		trinket_button.connect("mouse_exited", _on_trinket_hover_exit)

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


func _on_trinket_hover(trinket: Trinket):
	%TrinketInfo.text = trinket.description
	%TrinketIconEnlarged.texture = trinket.icon
	%TrinketInfoContainer.show()

func _on_trinket_hover_exit():
	%TrinketInfoContainer.hide()

extends Panel

var prior_focused_element: Variant

var on = false

var last_focused_idx = 0

func _ready():
	for i in range(GameManager.player.trinkets.size()):
		var trinket: Trinket = GameManager.player.trinkets[i]
		var trinket_button: Button = %TrinketIconContainer.get_child(i)
		trinket_button.icon = trinket.icon
		trinket_button.mouse_entered.connect(func(): steal_focus(i))
		trinket_button.mouse_exited.connect(return_focus)
		trinket_button.focus_entered.connect(func(): _display_trinket_info(i))
		trinket_button.focus_exited.connect(_hide_trinket_info)

func _display_trinket_info(index: int):
	%TrinketInfoSpritePanel.visible = true
	%TrinketInfoLabel.visible = true
	var trinket: Trinket = GameManager.player.trinkets[index]

	%TrinketInfoSprite.texture = trinket.icon

	%TrinketInfoLabel.text = "[center]%s[/center]\n%s" % [trinket.trinket_name, trinket.description]
	last_focused_idx = index

func _hide_trinket_info():
	%TrinketInfoLabel.hide()
	%TrinketInfoSpritePanel.hide()

func steal_focus(index):
	var focus_owner = get_viewport().gui_get_focus_owner()
	
	if not %TrinketIconContainer.is_ancestor_of(focus_owner):
		prior_focused_element = focus_owner

	get_child(0).get_child(index).grab_focus()
	on = true

func return_focus():
	prior_focused_element.grab_focus()
	on = false

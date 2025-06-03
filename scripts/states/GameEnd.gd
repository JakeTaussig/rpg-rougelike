extends AttackingInfoState

func enter(_messages: Array = []):
	var player = %Player
	var enemy = %Enemy

	var message = ""
	if enemy.selected_monster.hp <= 0:
		message = "%s defeated %s!" % [player.selected_monster.character_name, enemy.selected_monster.character_name]
	if player.selected_monster.hp <= 0:
		message = "%s defeated %s!" % [enemy.selected_monster.character_name, player.selected_monster.character_name]

	super.enter([message])

func handle_continue():
	get_tree().quit()

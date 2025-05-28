extends AttackingInfoState

func enter(_messages: Array = []):
	var player = battle.get_node("%Player")
	var enemy = battle.enemies[0]

	var message = ""
	if enemy.hp <= 0:
		message = "%s defeated %s!" % [player.character_name, enemy.character_name]
	if player.hp <= 0:
		message = "%s defeated %s!" % [enemy.character_name, player.character_name]

	super.enter([message])

func handle_continue():
	get_tree().quit()

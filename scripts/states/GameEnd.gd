extends AttackingInfoState

func enter(_messages: Array = []):
	var player = battle.get_node("%Player")
	var enemy = battle.enemies[0]

	var message = ""
	if enemy.monster.hp <= 0:
		message = "%s defeated %s!" % [player.monster.character_name, enemy.monster.character_name]
	if player.monster.hp <= 0:
		message = "%s defeated %s!" % [enemy.monster.character_name, player.monster.character_name]

	super.enter([message])

func handle_continue():
	get_tree().quit()

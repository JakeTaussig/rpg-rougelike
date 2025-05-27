extends AttackingInfoState

func enter(_messages: Array = []):
	var message = ""
	if battle_system.enemy.hp <= 0:
		message = "%s defeated %s!" % [%Player.character_name, battle_system.enemy.character_name]
	if %Player.hp <= 0:
		message = "%s defeated %s!" % [battle_system.enemy.character_name, %Player.character_name]

	super.enter([message])

func handle_continue():
	get_tree().quit()

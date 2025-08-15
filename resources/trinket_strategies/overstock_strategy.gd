class_name OverstockTrinketStrategy
extends TrinketStrategy


func ApplyEffect(monster: Monster):
	GameManager.N_TRINKETS += 1
	GameManager.current_shop._roll_trinkets()
	GameManager.current_shop.init_trinket_menu_button(GameManager.N_TRINKETS - 1)
	GameManager.current_shop._render_trinkets()

class_name SteamSaleTrinketStrategy
extends TrinketStrategy


func ApplyEffect(monster: Monster):
	GameManager.CONSUMABLE_COST = int(float(GameManager.CONSUMABLE_COST) * 0.5)
	GameManager.TRINKET_COST = int(float(GameManager.TRINKET_COST) * 0.5)

	GameManager.current_shop._render_trinkets()
	GameManager.current_shop._render_consumables()

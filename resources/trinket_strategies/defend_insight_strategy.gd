extends TrinketStrategy
class_name DefendInsightStrategy

func ApplyEffect(monster: Monster):
	GameManager.reveal_enemy_defending_stats = true

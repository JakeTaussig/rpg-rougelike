class_name AttackInsightStrategy
extends TrinketStrategy


func ApplyEffect(monster: Monster):
	GameManager.reveal_enemy_attacking_stats = true

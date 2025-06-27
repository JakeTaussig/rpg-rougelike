class_name Trinket extends Resource

# Determines when and where the trinket's effect is applied
enum TrinketCategory { ATK, TYPE }
@export var trinket_name: String = "Transform"
@export var icon: CompressedTexture2D = load("res://assets/sprites/trinket_icons/skull.png")
@export var description: String = "Change the player's type"

@export var strategy: TrinketStrategy = TrinketStrategy.new()

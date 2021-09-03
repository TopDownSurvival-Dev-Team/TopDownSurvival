extends Node2D

var health = 100


remote func damage_s(damage_amount: int):
	health -= damage_amount
	
	if health > 0:
		rpc("damage", damage_amount)
	else:
		get_tree().call_group("World", "despawn_tree_s", int(name))

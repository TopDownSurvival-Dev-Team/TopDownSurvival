extends Node2D

var health = 100


remote func damage_s(damage_amount: int):
	health -= damage_amount
	
	if health > 0:
		rpc("damage", damage_amount)
	else:
		break_tree()


func break_tree():
	# Despawn tree
	get_tree().call_group("World", "despawn_tree_s", int(name))
	
	# Spawn wood at current position
	get_tree().call_group("World", "spawn_item_s", "wood", global_position)

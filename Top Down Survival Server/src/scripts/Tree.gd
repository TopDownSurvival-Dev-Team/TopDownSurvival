extends Node2D

const MAX_WOOD_DROP = 5
const MIN_WOOD_DROP = 2

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
	var wood_quantity = (randi() % (MAX_WOOD_DROP - MIN_WOOD_DROP)) + MIN_WOOD_DROP
	get_tree().call_group("World", "spawn_item_s", "10001", wood_quantity, global_position)

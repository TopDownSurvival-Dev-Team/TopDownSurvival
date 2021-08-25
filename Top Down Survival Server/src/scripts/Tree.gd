extends Node2D

var health = 100


remote func damage_s(damage_amount: int):
	health -= damage_amount
	
	if health > 0:
		rpc("damage", damage_amount)
	else:
		break_tree_s()


func break_tree_s():
	rpc("break_tree")
	get_parent().remove_child(self)
	queue_free()

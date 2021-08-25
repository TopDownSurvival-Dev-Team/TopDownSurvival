extends Node2D


remote func damage_s(damage_amount: int):
	rpc("damage", damage_amount)


remote func break_tree_s():
	rpc("break_tree")
	get_parent().remove_child(self)
	queue_free()

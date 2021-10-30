extends Node


remote func fetch_inventory_s():
	var id = get_tree().get_rpc_sender_id()
	var player_uid = Network.players[id]["firebase_uid"]
	
	var inventory_data = Database.get_inventory(player_uid)
	rpc_id(id, "fetch_inventory", inventory_data)
	
	
func add_item_s(player_id: int, item_id: String, quantity: int):
	# TODO
	pass

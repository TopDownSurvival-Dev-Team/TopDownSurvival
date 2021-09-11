extends Node


remote func fetch_inventory_s(player_id: int):
	# Make sure client fetches their own inventory
	var id = get_tree().get_rpc_sender_id()
	
	if id == player_id:
		var inventory_data = Database.get_inventory(player_id)
		rpc_id(id, "fetch_inventory", inventory_data)

extends Node2D


remote func pick_up_s():
	var id = get_tree().get_rpc_sender_id()
	var player_uid = Network.players[id]["firebase_uid"]
	
	# Remove item from scene
	
	# Update player inventory

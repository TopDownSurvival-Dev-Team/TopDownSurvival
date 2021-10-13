extends Node

remote func send_message_s(message_text: String):
	var sender_id = get_tree().get_rpc_sender_id()
	var sender = Network.players[sender_id]["username"]
	var message_text_formatted = message_text.strip_edges()
	
	if not message_text_formatted.empty():
		rpc("add_message", message_text_formatted, sender, "FFFFFF")
		
		
func send_join_message(player_name):
	var message_text = player_name + " has joined the game!"
	rpc("add_message", message_text, "Server", "F7E65E")
		
		
func send_leave_message(player_name):
	var message_text = player_name + " disconnected from the game!"
	rpc("add_message", message_text, "Server", "F7E65E")

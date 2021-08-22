extends Node

remote func send_message_s(message_text: String):
	var sender_id = get_tree().get_rpc_sender_id()
	var sender = Network.players[sender_id]["player_name"]
	var message_text_formatted = message_text.strip_edges()
	
	if not message_text_formatted.empty():
		rpc("add_message", message_text_formatted, sender, "FFFFFF")

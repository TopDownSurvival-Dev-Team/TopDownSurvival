extends Node

var currently_open_menus = []


func show_menu_s(
	player_id: int, container_name: String, container_position: Vector2
):
	if not currently_open_menus.has(player_id):
		var container_id = Database.get_container_id(container_position)

		if container_id:
			var player_uid = Network.players[player_id]["firebase_uid"]
			var inventory_data = Database.get_inventory(player_uid)
			var items = Database.get_container_items(container_id)
			rpc_id(player_id, "show_menu", container_name, inventory_data, items)
			currently_open_menus.append(player_id)


remote func close_menu_s():
	var player_id = get_tree().get_rpc_sender_id()
	currently_open_menus.erase(player_id)

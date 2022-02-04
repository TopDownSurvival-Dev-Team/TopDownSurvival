extends Node


func show_menu_s(
	player_id: int, container_name: String, container_position: Vector2
):
	var container_id = Database.get_container_id(container_position)
	var items = Database.get_container_items(container_id)
	rpc_id(player_id, "show_menu", container_name, items)

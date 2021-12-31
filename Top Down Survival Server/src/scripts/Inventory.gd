extends Node

signal item_dropped(item_id, quantity, player_id)


remote func fetch_inventory_s():
    var id = get_tree().get_rpc_sender_id()
    var player_uid = Network.players[id]["firebase_uid"]

    var inventory_data = Database.get_inventory(player_uid)
    rpc_id(id, "fetch_inventory", inventory_data)


remote func on_item_dropped_s(item_id, quantity):
    if quantity > 0:
        var id = get_tree().get_rpc_sender_id()
        remove_item_s(id, item_id, quantity)
        emit_signal("item_dropped", item_id, quantity, id)


func add_item_s(player_id: int, item_id: String, quantity: int):
    var player_uid = Network.players[player_id]["firebase_uid"]
    var current_quantity = Database.get_item_quantity(player_uid, item_id)

    if current_quantity:
        current_quantity += quantity
        Database.set_item_quantity(player_uid, item_id, current_quantity)
        rpc_id(player_id, "update_item", item_id, current_quantity)
    else:
        Database.create_new_item(player_uid, item_id, quantity)
        rpc_id(player_id, "add_item", item_id, quantity)


func remove_item_s(player_id: int, item_id: String, quantity: int):
    var player_uid = Network.players[player_id]["firebase_uid"]
    var current_quantity = Database.get_item_quantity(player_uid, item_id)

    if current_quantity:
        current_quantity -= quantity
        if current_quantity > 0:
            Database.set_item_quantity(player_uid, item_id, current_quantity)
            rpc_id(player_id, "update_item", item_id, current_quantity)
        else:
            Database.remove_item(player_uid, item_id)
            rpc_id(player_id, "remove_item", item_id)

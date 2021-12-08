extends Control

const INVENTORY_ROW_SCENE = preload("res://src/scenes/ui_scenes/templates/InventoryRow.tscn")

onready var row_container = $V/SC/RowContainer


func _ready():
    # Remove preview slots
    for row in row_container.get_children():
        row_container.remove_child(row)
        row.queue_free()

    rpc_id(1, "fetch_inventory_s")


remote func fetch_inventory(inventory_data: Array):
    for item_info in inventory_data:
        var item_id = item_info["item_id"]
        var item_quantity = item_info["quantity"]
        add_item(item_id, item_quantity)


remote func add_item(item_id: String, quantity: int):
    var new_inv_row = INVENTORY_ROW_SCENE.instance()
    new_inv_row.init(item_id, quantity)
    row_container.add_child(new_inv_row)
    new_inv_row.connect("item_dropped", self, "on_item_dropped")


remote func remove_item(item_id: String):
    var inv_row = row_container.get_node("Inv%s" % item_id)
    row_container.remove_child(inv_row)
    inv_row.queue_free()


remote func update_item(item_id: String, quantity: int):
    var inv_row = row_container.get_node("Inv%s" % item_id)
    inv_row.set_quantity(quantity)


func on_item_dropped(item_id, quantity):
    rpc_id(1, "on_item_dropped_s", item_id, quantity)

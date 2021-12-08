extends Control

signal item_dropped(item_id, quantity)

export var preview: bool = false
var item_id: String
var quantity: int
var item_name: String

onready var info_label = $H/H/Info
onready var icon = $H/H/Icon


func init(_item_id: String, _quantity: int):
    item_id = _item_id
    quantity = _quantity
    item_name = GameData.item_data[item_id]["name"]
    name = "Inv%s" % item_id


func _ready():
    if preview:
        return

    info_label.text = "%s (x%s)" % [item_name, quantity]

    var lower_name = item_name.to_lower()
    var image_path = "res://assets/items/%s/%s.png" % [lower_name, lower_name]
    var image = load(image_path)
    icon.texture = image


func set_quantity(new_quantity: int):
    quantity = new_quantity
    info_label.text = "%s (x%s)" % [item_name, quantity]


func _on_DropButton_pressed():
    emit_signal("item_dropped", item_id, 1)
    # TODO: Add a way to control how many items are dropped

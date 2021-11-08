extends Node2D
class_name Item

signal picked_up(item, player_id)

var item_id: String
var quantity: int


func init(scene_name: String, _item_id: String, _quantity: int):
    name = scene_name
    item_id = _item_id
    quantity = _quantity


remote func pick_up_s():
    var id = get_tree().get_rpc_sender_id()
    emit_signal("picked_up", self, id)

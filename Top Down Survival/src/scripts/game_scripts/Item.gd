extends StaticBody2D
class_name Item

var item_id: String
var quantity: int


func init(scene_name: String, _item_id: String, _quantity: int):
	name = scene_name
	item_id = _item_id
	quantity = _quantity
	
	
func request_pick_up():
	rpc_id(1, "pick_up_s")

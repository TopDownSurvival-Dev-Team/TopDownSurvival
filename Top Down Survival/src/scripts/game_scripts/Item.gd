extends StaticBody2D
class_name Item

const PICK_UP_SFX_SCENE = preload("res://src/audio_streams/ItemPickUpSFX.tscn")

var item_id: String
var quantity: int
var pick_up_sfx = PICK_UP_SFX_SCENE.instance()

onready var collision_shape = get_node("CollisionShape2D")


func init(scene_name: String, _item_id: String, _quantity: int):
    name = scene_name
    item_id = _item_id
    quantity = _quantity


func _ready():
    add_child(pick_up_sfx)
    pick_up_sfx.global_position = global_position
    pick_up_sfx.connect("finished", self, "_on_ItemPickUpSFX_finished")


func request_pick_up():
    rpc_id(1, "pick_up_s")


func destroy():
    visible = false
    collision_shape.set_disabled(true)
    pick_up_sfx.play()


func _on_ItemPickUpSFX_finished():
    get_parent().remove_child(self)
    queue_free()

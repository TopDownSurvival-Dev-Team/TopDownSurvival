extends StaticBody2D
class_name Item

const PICK_UP_SFX_SCENE = preload("res://src/audio_streams/ItemPickUpSFX.tscn")
const DROP_SFX_SCENE = preload("res://src/audio_streams/ItemDropSFX.tscn")

var item_id: String
var quantity: int
var dropped: bool

var pick_up_sfx = PICK_UP_SFX_SCENE.instance()
var drop_sfx = DROP_SFX_SCENE.instance()

onready var collision_shape = get_node("CollisionShape2D")


func init(scene_name: String, _item_id: String, _quantity: int, _dropped: bool):
    name = scene_name
    item_id = _item_id
    quantity = _quantity
    dropped = _dropped


func _ready():
    add_child(pick_up_sfx)
    pick_up_sfx.global_position = global_position
    pick_up_sfx.connect("finished", self, "_on_ItemPickUpSFX_finished")

    add_child(drop_sfx)
    drop_sfx.global_position = global_position

    if dropped:
        drop_sfx.play()


func request_pick_up():
    rpc_id(1, "pick_up_s")


func destroy():
    visible = false
    collision_shape.set_disabled(true)
    pick_up_sfx.play()


func _on_ItemPickUpSFX_finished():
    get_parent().remove_child(self)
    queue_free()

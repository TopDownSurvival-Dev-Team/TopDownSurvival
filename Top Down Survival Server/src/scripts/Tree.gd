extends Node2D
class_name GameTree

signal on_break(tree)

const MAX_WOOD_DROP = 6
const MIN_WOOD_DROP = 3
const ITEM_DROP = "10001"

var health = 100
var wood_quantity: int


func _ready():
    wood_quantity = (randi() % (MAX_WOOD_DROP - MIN_WOOD_DROP)) + MIN_WOOD_DROP


remote func damage_s(damage_amount: int):
    health -= damage_amount

    if health > 0:
        rpc("damage", damage_amount)
    else:
        emit_signal("on_break", self)

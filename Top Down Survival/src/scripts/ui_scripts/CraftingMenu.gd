extends Control

onready var inventory = $H/Inventory
onready var inventory_bg = $H/Inventory/Background


func _ready():
    inventory_bg.visible = false

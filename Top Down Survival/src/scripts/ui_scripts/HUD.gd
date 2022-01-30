extends CanvasLayer

signal focus_entered
signal focus_exited

onready var inventory = $Inventory


func _ready():
    for node in get_children():
        node.connect("focus_entered", self, "on_focus_entered")
        node.connect("focus_exited", self, "on_focus_exited")


func on_focus_entered():
    emit_signal("focus_entered")


func on_focus_exited():
    emit_signal("focus_exited")

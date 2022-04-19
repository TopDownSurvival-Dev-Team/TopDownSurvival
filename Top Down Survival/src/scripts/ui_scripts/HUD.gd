extends CanvasLayer

signal focus_entered
signal focus_exited

onready var inventory = $Inventory
onready var crafting_menu = $CraftingMenu
onready var container_menu = $ContainerMenu
onready var pause_menu = $PauseMenu


func _ready():
	for node in get_children():
		node.connect("focus_entered", self, "on_focus_entered")
		node.connect("focus_exited", self, "on_focus_exited")


func is_any_ui_visible() -> bool:
	return (
		crafting_menu.visible or
		container_menu.visible or
		pause_menu.visible
	)


func on_focus_entered():
	emit_signal("focus_entered")


func on_focus_exited():
	emit_signal("focus_exited")

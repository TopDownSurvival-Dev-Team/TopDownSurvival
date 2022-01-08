extends Control

const INVENTORY_ROW_SCENE = preload("res://src/scenes/ui_scenes/templates/InventoryRow.tscn")
const RECIPE_ROW_SCENE = preload("res://src/scenes/ui_scenes/templates/RecipeRow.tscn")

onready var inventory_container = $H/Inventory/SC/V
onready var recipe_container = $H/Recipes/SC/V


func _ready():
    # Clear preview items
    clear_all_items()


func clear_all_items():
    for node in inventory_container.get_children():
        inventory_container.remove_child(node)
        node.queue_free()

    for node in recipe_container.get_children():
        recipe_container.remove_child(node)
        node.queue_free()


remote func show_menu(inventory_data: Array, recipes: Dictionary):
    clear_all_items()

    for item_info in inventory_data:
        var item_id = item_info["item_id"]
        var item_quantity = item_info["quantity"]
        add_inventory_item(item_id, item_quantity)

    for item_id in recipes:
        var ingredients = recipes[item_id]
        add_recipe_item(item_id, ingredients)


func add_inventory_item(item_id: String, quantity: int):
    var new_inv_row = INVENTORY_ROW_SCENE.instance()
    new_inv_row.init(item_id, quantity)
    inventory_container.add_child(new_inv_row)


remote func remove_inventory_item(item_id: String):
    var inv_row = inventory_container.get_node("Inv%s" % item_id)
    inventory_container.remove_child(inv_row)
    inv_row.queue_free()


remote func update_inventory_item(item_id: String, quantity: int):
    var inv_row = inventory_container.get_node("Inv%s" % item_id)
    inv_row.set_quantity(quantity)


func add_recipe_item(item_id: String, ingredients: Dictionary):
    var new_recipe_row = RECIPE_ROW_SCENE.instance()
    new_recipe_row.init(item_id, ingredients)
    recipe_container.add_child(new_recipe_row)

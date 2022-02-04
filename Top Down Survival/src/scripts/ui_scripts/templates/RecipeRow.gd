extends Control

signal craft_button_pressed(item_id)

export var preview: bool = false
var item_id: String
var ingredients: Dictionary

onready var icon = $H/Icon
onready var item_name_label = $H/V/ItemNameLabel
onready var ingredients_label = $H/V/IngredientsLabel


func init(_item_id: String, _ingredients: Dictionary):
	item_id = _item_id
	ingredients = _ingredients
	name = "Recipe%s" % item_id


func _ready():
	if preview:
		return

	var item_name = GameData.item_data[item_id]["name"]
	item_name_label.set_text(item_name)

	var ingredient_texts = PoolStringArray()
	for ingredient_id in ingredients:
		var ingredient_name = GameData.item_data[ingredient_id]["name"]
		var quantity = ingredients[ingredient_id]
		ingredient_texts.append("%s x%s" % [ingredient_name, quantity])
	ingredients_label.set_text("(%s)" % ingredient_texts.join(", "))

	var lower_name = item_name.to_lower().split(" ").join("_")
	var image_path = "res://assets/items/%s/%s.png" % [lower_name, lower_name]
	var image = load(image_path)
	icon.texture = image


func _on_CraftButton_pressed():
	emit_signal("craft_button_pressed", item_id)

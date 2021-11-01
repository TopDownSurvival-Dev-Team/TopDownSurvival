extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
const DB_PATH = "res://data/database"

var db = SQLite.new()


func _ready():
	init_db()
	create_tables()
	
	
func init_db():
	db.path = DB_PATH
	db.open_db()
	
	
func create_tables():
	# Inventory Table
	db.query("""
	CREATE TABLE IF NOT EXISTS inventories (
		player_uid	TEXT NOT NULL,
		item_id	TEXT NOT NULL,
		quantity	INTEGER NOT NULL DEFAULT 1
	)
	""")
	
	
func get_inventory(player_uid: String) -> Array:
	db.query("""
		SELECT item_id, quantity
		FROM inventories
		WHERE player_uid = \"%s\"
	""" % player_uid)
	return db.query_result
	
	
func create_new_item(player_uid: String, item_id: String, quantity: int):
	db.query("""
		INSERT INTO inventories (player_uid, item_id, quantity)
		VALUES (\"%s\", \"%s\", %s)
	""" % [player_uid, item_id, quantity])
	
	
func get_item_quantity(player_uid: String, item_id: String):  # int or null
	db.query("""
		SELECT quantity
		FROM inventories
		WHERE player_uid = \"%s\" AND item_id = \"%s\"
	""" % [player_uid, item_id])
	
	if db.query_result:
		return db.query_result[0]["quantity"]
	return null
	
	
func set_item_quantity(player_uid: String, item_id: String, quantity: int):
	db.query("""
		UPDATE inventories
		SET quantity = %s
		WHERE player_uid = \"%s\" AND item_id = \"%s\"
	""" % [quantity, player_uid, item_id])

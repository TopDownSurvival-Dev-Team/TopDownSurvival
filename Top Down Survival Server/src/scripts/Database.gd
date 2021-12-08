extends Node

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
const DB_PATH = "user://database"

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

    db.query("""
        CREATE TABLE IF NOT EXISTS world (
            entity_type	TEXT NOT NULL,
            x_position	INTEGER NOT NULL,
            y_position	INTEGER NOT NULL,
            entity_info	TEXT NOT NULL DEFAULT "{}"
        )
    """)

    db.query("""
        CREATE TABLE IF NOT EXISTS player_positions (
            player_uid	TEXT NOT NULL,
            x_position	INTEGER NOT NULL,
            y_position	INTEGER NOT NULL
        )
    """)


func get_player_position(player_uid: String):  # Vector2 or null
    db.query("""
        SELECT x_position, y_position
        FROM player_positions
        WHERE player_uid = \"%s\"
    """ % player_uid)
    
    if db.query_result:
        var x = db.query_result[0]["x_position"]
        var y = db.query_result[0]["y_position"]
        return Vector2(x, y)
    return null


func set_player_position(player_uid: String, position: Vector2):
    var current_pos = get_player_position(player_uid)

    if current_pos:
        db.query("""
            UPDATE player_positions
            SET x_position = %s, y_position = %s
            WHERE player_uid = \"%s\"
        """ % [position.x, position.y, player_uid])
    else:
        db.query("""
            INSERT INTO player_positions
            VALUES (\"%s\", %s, %s)
        """ % [player_uid, position.x, position.y])


func get_world_data() -> Array:
    var world_data = []
    db.query("SELECT * FROM world")

    for entity_data in db.query_result:
        var data = {
            "entity_type": entity_data["entity_type"],
            "position": Vector2(entity_data["x_position"], entity_data["y_position"]),
            "entity_info": parse_json(entity_data["entity_info"])
        }
        world_data.append(data)

    return world_data


func save_world_data(world_data: Array):
    db.query("DELETE FROM world")

    for entity_data in world_data:
        var entity_type = entity_data["entity_type"]
        var position = entity_data["position"]
        var entity_info = to_json(entity_data["entity_info"])

        db.query("""
            INSERT INTO world VALUES ('%s', %s, %s, '%s')
        """ % [entity_type, position.x, position.y, entity_info])


func get_inventory(player_uid: String) -> Array:
    db.query("""
        SELECT item_id, quantity
        FROM inventories
        WHERE player_uid = \"%s\"
    """ % player_uid)
    return db.query_result


func create_new_item(player_uid: String, item_id: String, quantity: int):
    db.query("""
        INSERT INTO inventories
        VALUES (\"%s\", \"%s\", %s)
    """ % [player_uid, item_id, quantity])


func remove_item(player_uid: String, item_id: String):
    db.query("""
        DELETE FROM inventories
        WHERE player_uid = \"%s\" AND item_id = \"%s\"
    """ % [player_uid, item_id])


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

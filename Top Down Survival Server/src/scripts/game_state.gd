extends Node2D

const PLAYER_SCENE = preload("res://src/scenes/Player.tscn")
const TREE_SCENE = preload("res://src/scenes/Tree.tscn")
const ITEM_SCENE = preload("res://src/scenes/Item.tscn")

const MAX_TREE_COUNT = 100
const TREE_POS_RANGE = Vector2(5000, 5000)

const MAX_ITEM_COUNT = 99

var world_loaded = false
var block_data = {}

onready var inventory = $HUD/Inventory
onready var blocks = $Blocks
onready var players = $Players
onready var trees = $Trees
onready var items = $Items
onready var player_spawn = $PlayerSpawn


func _ready():
    print("Game world started!")
    get_tree().set_auto_accept_quit(false)

    # Randomize RNG seed
    randomize()

    # Wait till connected to game server hub
    GameServerHub.connect_to_hub()
    yield(GameServerHub.network, "connection_succeeded")

    # Connect signals
    Network.connect("player_joined_game", self, "send_world_to")
    Network.connect("player_joined_game", self, "spawn_player_s")
    Network.connect("player_left_game", self, "despawn_player_s")

    # Load world before letting players connect
    var world_data = Database.get_world_data()

    if world_data.empty():
        generate_world()
        save_world()
    else:
        load_world(world_data)

    world_loaded = true
    Network.start_server()


func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST and world_loaded:
        save_world()
        get_tree().quit()


func load_world(world_data: Array):
    print("Loading world...")

    for entity_data in world_data:
        var entity_type = entity_data["entity_type"]
        var entity_pos = entity_data["position"]
        var entity_info = entity_data["entity_info"]

        match entity_type:
            "tree":
                spawn_tree_s(entity_pos)

            "block":
                var world_position = blocks.map_to_world(entity_pos) * blocks.scale
                spawn_block_s(entity_info["block_id"], world_position, false)

            _:
                var quantity = entity_info["quantity"]
                spawn_item_s(entity_type, quantity, entity_pos, false)

    print("Loaded world!")


func save_world():
    print("Saving world...")
    var world_data = []

    for player in players.get_children():
        var id = player.name.to_int()
        var player_uid = Network.players[id]["firebase_uid"]
        Database.set_player_position(player_uid, player.global_position)

    for tree in trees.get_children():
        var data = {
            "entity_type": "tree",
            "position": tree.global_position,
            "entity_info": {}
        }
        world_data.append(data)

    for block_pos in block_data:
        var data = {
            "entity_type": "block",
            "position": block_pos,
            "entity_info": {
                "block_id": block_data[block_pos]
            }
        }
        world_data.append(data)

    for item in items.get_children():
        var data = {
            "entity_type": item.item_id,
            "position": item.global_position,
            "entity_info": {
                "quantity": item.quantity
            }
        }
        world_data.append(data)

    Database.save_world_data(world_data)
    print("Saved world!")


func generate_world():
    print("Generating world...")

    print("Generating natural structures")

    for _i in range(MAX_TREE_COUNT):
        var new_tree_pos = Vector2(
            randi() % int(TREE_POS_RANGE.x) - TREE_POS_RANGE.x / 2,
            randi() % int(TREE_POS_RANGE.y) - TREE_POS_RANGE.y / 2
        )
        spawn_tree_s(new_tree_pos)


func send_world_to(id):
    print("Syncing TileMaps")
    blocks.sync_tilemap_s(id)

    print("Sending players to " + str(id))
    for player in players.get_children():
        var player_id = player.name.to_int()
        if player_id != id:
            rpc_id(id, "spawn_player", player_id, player.global_position)

    print("Sending natural structures to " + str(id))
    for tree in trees.get_children():
        rpc_id(id, "spawn_tree", int(tree.name), tree.global_position)

    print("Sending man-made structures to " + str(id))
    for block_pos in block_data:
        var block_id = block_data[block_pos]
        var world_position = blocks.map_to_world(block_pos) * blocks.scale
        rpc_id(id, "spawn_block", block_id, world_position, false)

    print("Sending items to " + str(id))
    for item in items.get_children():
        var item_info = item.name.split("-", false, 1)
        var scene_id = item_info[1].to_int()
        rpc_id(id, "spawn_item", item.item_id, item.quantity, scene_id, item.global_position, false)




func spawn_player_s(id: int):
    print("Spawning player " + str(id))

    var player_uid = Network.players[id]["firebase_uid"]
    var player_position = Database.get_player_position(player_uid)

    if not player_position:
        player_position = player_spawn.global_position

    var new_player = PLAYER_SCENE.instance()
    new_player.name = str(id)
    new_player.global_position = player_position
    players.add_child(new_player, true)

    rpc("spawn_player", id, player_position)


func despawn_player_s(id: int):
    print("Despawning player " + str(id))
    var player = players.get_node(str(id))

    if player:
        # Save player position
        var player_uid = Network.players[id]["firebase_uid"]
        Database.set_player_position(player_uid, player.global_position)

        players.remove_child(player)
        player.queue_free()

        rpc("despawn_player", id)




func spawn_tree_s(tree_position: Vector2):
    var scene_id = randi() % MAX_TREE_COUNT

    # Make sure scene_id is unique
    while trees.get_node_or_null(str(scene_id)) != null:
        scene_id = randi() % MAX_TREE_COUNT

    var new_tree = TREE_SCENE.instance()
    new_tree.name = str(scene_id)
    new_tree.connect("on_break", self, "on_tree_break")
    trees.add_child(new_tree, true)
    new_tree.global_position = tree_position

    if Network.get_peer_count() > 0:
        rpc("spawn_tree", int(new_tree.name), new_tree.global_position)


func despawn_tree_s(scene_id: int):
    var tree = trees.get_node(str(scene_id))
    trees.remove_child(tree)
    tree.queue_free()

    if tree and Network.get_peer_count() > 0:
        rpc("despawn_tree", scene_id)


func on_tree_break(tree: GameTree):
    # Spawn wood at current position
    spawn_item_s(tree.ITEM_DROP, tree.wood_quantity, tree.global_position, false)

    # Despawn tree
    despawn_tree_s(tree.name.to_int())




func spawn_item_s(item_id: String, quantity: int, item_position: Vector2, dropped: bool):
    # Limit number of item nodes currently existing
    if items.get_child_count() >= MAX_ITEM_COUNT:
        var remove_item: Item = items.get_child(0)

        # Get item info
        var item_info = remove_item.name.split("-", false, 1)
        var r_item_id = remove_item.item_id
        var r_scene_id = item_info[1].to_int()

        despawn_item_s(r_item_id, r_scene_id)

    # Create the item
    var new_item = ITEM_SCENE.instance()

    # Gather item info
    var item_type = GameData.item_data[item_id]["name"]
    var scene_id = randi() % MAX_ITEM_COUNT
    var scene_name = str(item_type) + "-" + str(scene_id)

    # Make sure scene_name is unique
    while items.get_node_or_null(scene_name) != null:
        scene_id = randi() % MAX_ITEM_COUNT

        scene_name = str(item_type) + "-" + str(scene_id)

    new_item.init(scene_name, item_id, quantity)
    new_item.connect("picked_up", self, "on_item_picked_up")

    items.add_child(new_item, true)
    new_item.global_position = item_position

    if Network.get_peer_count() > 0:
        rpc("spawn_item", item_id, quantity, scene_id, item_position, dropped)


func despawn_item_s(item_id: String, scene_id: int):
    var item_type = GameData.item_data[item_id]["name"]
    var scene_name = str(item_type) + "-" + str(scene_id)
    var item = items.get_node(scene_name)
    items.remove_child(item)
    item.queue_free()

    if item and Network.get_peer_count() > 0:
        rpc("despawn_item", item_id, scene_id)


func on_item_picked_up(item: Item, player_id: int):
    # Remove item from scene
    var scene_id = item.name.split("-")[1].to_int()
    despawn_item_s(item.item_id, scene_id)

    # Update player inventory
    inventory.add_item_s(player_id, item.item_id, item.quantity)


func on_item_dropped(item_id: String, quantity: int, player_id: int):
    var player: Node2D = players.get_node(str(player_id))
    var player_position = player.global_position

    # Get player direction vector
    var player_direction = Vector2(
        cos(player.rotation),
        sin(player.rotation)
    )

    var item_position = player_position + player_direction * 64
    spawn_item_s(item_id, quantity, item_position, true)




func spawn_block_s(block_id: String, world_position: Vector2, player_placed: bool):
    var map_position = blocks.world_to_map(world_position / blocks.scale)
    block_data[map_position] = block_id

    if Network.get_peer_count() > 0:
        rpc("spawn_block", block_id, world_position, player_placed)


func despawn_block_s(world_position: Vector2):
    var map_position = blocks.world_to_map(world_position / blocks.scale)
    block_data.erase(map_position)

    if Network.get_peer_count() > 0:
        rpc("despawn_block", world_position)


remote func request_block_change(block_id: String, world_position: Vector2, destroy: bool):
    var sender_id = get_tree().get_rpc_sender_id()
    var player_uid = Network.players[sender_id]["firebase_uid"]
    var player_position = players.get_node(str(sender_id)).global_position

    # Make sure the position is within player's reach
    if world_position.distance_to(player_position) <= GameData.PLAYER_REACH:
        if destroy:
            var map_position = blocks.world_to_map(world_position / blocks.scale)
            var destroyed_block_id = block_data.get(map_position)

            # Add the destroyed block to player's inventory
            if destroyed_block_id:
                despawn_block_s(world_position)
                inventory.add_item_s(sender_id, destroyed_block_id, 1)

        else:
            var map_position = blocks.world_to_map(world_position / blocks.scale)

            # Don't do anything if theres already a block at the position
            if not block_data.get(map_position):
                var item_data = GameData.item_data[block_id]
                var current_quantity = Database.get_item_quantity(player_uid, block_id)

                # Verify the item is placeable and the player has it in their inventory
                if item_data["type"] == "Block" and current_quantity:
                    spawn_block_s(block_id, world_position, true)
                    inventory.remove_item_s(sender_id, block_id, 1)

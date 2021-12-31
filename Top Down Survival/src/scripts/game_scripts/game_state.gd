extends Node2D

const PLAYER_SCENE = preload("res://src/actors/Player.tscn")
const TREE_SCENE  = preload("res://src/actors/Tree.tscn")
const BLOCK_PLACE_SFX = preload("res://src/audio_streams/BlockPlaceSFX.tscn")
const BLOCK_BREAK_SFX = preload("res://src/audio_streams/BlockBreakSFX.tscn")
const GROUND_TILE_ID = 0

var master_player_ready = false

onready var hud = $HUD
onready var blocks = $Blocks
onready var players = $Players
onready var trees = $Trees
onready var items = $Items


func _ready():
    randomize()


func _input(event: InputEvent):
    # TODO: Make blocks take time to break
    if not master_player_ready:
        return

    var mouse_position = get_global_mouse_position()
    var master_player = $Players.get_node(str(Network.local_player_id))
    var player_distance = mouse_position.distance_to(master_player.global_position)

    if player_distance <= GameData.player_reach:
        if event.is_action_pressed("attack"):
            rpc_id(1, "request_block_change", "", mouse_position, true)

        elif event.is_action_pressed("use"):
            var item_id = hud.inventory.selected_item_id
            if item_id:
                var item_data = GameData.item_data[item_id]

                if item_data["type"] == "Block":
                    rpc_id(1, "request_block_change", item_id, mouse_position, false)




remote func spawn_player(player_id: int, player_position: Vector2):
    print("Spawning player " + str(player_id))

    var new_player = PLAYER_SCENE.instance()
    new_player.name = str(player_id)
    players.add_child(new_player, true)

    new_player.set_network_master(player_id)
    new_player.global_position = player_position

    if new_player.is_network_master():
        master_player_ready = true
        hud.connect("focus_entered", new_player, "on_gui_focus_entered")
        hud.connect("focus_exited", new_player, "on_gui_focus_exited")


remote func despawn_player(player_id: int):
    print("Despawning player " + str(player_id))
    var player = players.get_node(str(player_id))

    if player:
        players.remove_child(player)
        player.queue_free()




remote func spawn_tree(tree_id: int, tree_position: Vector2):
    var new_tree = TREE_SCENE.instance()

    new_tree.name = str(tree_id)
    trees.add_child(new_tree, true)

    new_tree.global_position = tree_position


remote func despawn_tree(tree_id: int):
    var tree = trees.get_node(str(tree_id))

    if tree:
        tree.destroy()




remote func spawn_item(item_id: String, quantity: int, scene_id: int, item_position: Vector2, dropped: bool):
    var item_type = GameData.item_data[item_id]["name"]
    var new_item_scene = load("res://src/actors/items/%s.tscn" % item_type)

    if new_item_scene:
        var scene_name = str(item_type) + "-" + str(scene_id)
        var new_item: Item = new_item_scene.instance()

        new_item.init(scene_name, item_id, quantity, dropped)
        items.add_child(new_item, true)
        new_item.global_position = item_position

    else:
        print("Item of type '%s' not found" % item_type)


remote func despawn_item(item_id: String, scene_id: int):
    var item_type = GameData.item_data[item_id]["name"]
    var scene_name = str(item_type) + "-" + str(scene_id)
    var item: Item = items.get_node(scene_name)

    if item:
        item.destroy()




remote func spawn_block(block_id: String, world_position: Vector2, player_placed: bool):
    var tile_id = blocks.tile_set.find_tile_by_name(block_id)
    var tile_set_pos = blocks.world_to_map(world_position / blocks.scale)
    blocks.set_cellv(tile_set_pos, tile_id)

    if player_placed:
        var sfx = BLOCK_PLACE_SFX.instance()
        sfx.global_position = world_position
        add_child(sfx)
        sfx.play()


remote func despawn_block(world_position: Vector2):
    var tile_set_pos = blocks.world_to_map(world_position / blocks.scale)
    blocks.set_cellv(tile_set_pos, GROUND_TILE_ID)

    var sfx = BLOCK_BREAK_SFX.instance()
    sfx.global_position = world_position
    add_child(sfx)
    sfx.play()

extends TileMap

# NOTE: This node only exists to sync tile map properties across the network,
# not to store block data. Block data is handled in game_state.gd.


func sync_tilemap_s(player_id: int):
    rpc_id(player_id, "sync_tilemap", cell_size, scale)

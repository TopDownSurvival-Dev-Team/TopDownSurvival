extends Node2D

remote func update_player(_transform, current_animation):
    transform = _transform
    rpc_unreliable("remote_update", _transform, current_animation)

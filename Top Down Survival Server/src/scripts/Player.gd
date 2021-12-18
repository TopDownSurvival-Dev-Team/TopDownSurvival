extends Node2D

var velocity = Vector2.ZERO


remote func update_player(_transform, _velocity, current_animation):
    transform = _transform
    velocity = _velocity
    rpc_unreliable("remote_update", transform, velocity, current_animation)

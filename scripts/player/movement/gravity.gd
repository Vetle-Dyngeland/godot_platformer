class_name Gravity
# PUBLIC
var held_down_gravity_multi := 1.5 # When you hold "move_down", how much gravity is multiplied by
var terminal_fall_velocity := 400.0 # Max speed you can fall
var held_down_fall_velocity_multi := 1.5 # How much terminal velocity increases when you hold "move_down"

var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _body: CharacterBody2D # The physics body the movement is applied to

func _init(
    character_body: CharacterBody2D, 
    held_down_gravity_multi_: float, 
    terminal_fall_velocity_: float,
    held_down_fall_velocity_multi_: float,
):
    _body = character_body
    # Default constructor like the other classes
    if held_down_gravity_multi_: held_down_gravity_multi = held_down_gravity_multi_
    if terminal_fall_velocity_: terminal_fall_velocity = terminal_fall_velocity_
    if held_down_fall_velocity_multi_: held_down_fall_velocity_multi = held_down_fall_velocity_multi_

func update(delta: float, input: float):
    if _body.is_on_floor(): return # Gravity shouldnt be applied when you're on the floor

    var gravity_force = _gravity * delta
    var terminal_velocity = terminal_fall_velocity # Just a mutable clone

    if input > 0.0: # If move_down is held
        gravity_force *= held_down_gravity_multi
        terminal_velocity *= held_down_fall_velocity_multi

    _body.velocity.y += gravity_force
    if _body.velocity.y > terminal_velocity: # If falling faster than allowed, dont
        _body.velocity.y = terminal_velocity

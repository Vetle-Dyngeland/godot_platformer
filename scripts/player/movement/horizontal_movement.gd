class_name HorizontalMovement
var max_speed := 100.0 # Max x speed
var acceleration_force := 500.0 # Force applied when accelerating
var decceleration_force := 500.0 # Force applied when deccelerating
var air_control_multi := 0.7 # How much acceleration is multiplied with when in the air
var air_friction_multi := 0.1 # How much decceleration is multiplied with when in the air
var turnaround_multi := 2.0 # How much acceleration is multiplied with when velocity and input does not match up

var _body: CharacterBody2D

# Just set all the public variables
func _init(
    character_body: CharacterBody2D,
    max_speed_: float, 
    acceleration_force_: float, 
    decceleration_force_: float,
    air_control_multi_: float,
    air_friction_multi_: float, 
    turnaround_multi_: float
    ):
    _body = character_body
    # If the given function property is not null, set the variable to the property
    if max_speed_: max_speed = max_speed_
    if acceleration_force_: acceleration_force = acceleration_force_
    if decceleration_force_: decceleration_force = decceleration_force_
    if air_control_multi_: air_control_multi = air_control_multi_
    if air_friction_multi_: air_friction_multi = air_friction_multi_
    if turnaround_multi_: turnaround_multi = turnaround_multi_

func update(delta: float, direction: float):
    # If actually pressing keys
    if abs(direction) > 0:
        _accelerate(delta, direction)
    else: _deccelerate(delta)

func _accelerate(delta: float, direction: float):
    var accel = acceleration_force * delta
    if not _body.is_on_floor():
        accel *= air_control_multi

    # If trying to move in the opposite direction, apply a boost to the acceleration
    if sign(direction) != sign(_body.velocity.x):
        accel *= turnaround_multi

    _body.velocity.x = move_toward(_body.velocity.x, max_speed * direction, accel) 

func _deccelerate(delta: float):
    var deccel = decceleration_force * delta
    if not _body.is_on_floor():
        deccel *= air_friction_multi

    _body.velocity.x = move_toward(_body.velocity.x, 0, deccel)

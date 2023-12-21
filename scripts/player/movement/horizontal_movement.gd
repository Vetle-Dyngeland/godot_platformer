class_name HorizontalMovement
var max_speed := 100.0 # Max x speed
var acceleration_force := 500.0 # Force applied when accelerating
var decceleration_force := 500.0 # Force applied when deccelerating
var air_control_multi := 0.7 # How much acceleration is multiplied with when in the air
var air_friction_multi := 0.1 # How much decceleration is multiplied with when in the air
var max_speed_friction_multi := 0.5 # How much decceleration is multiplied with when above max speed and moving the same direction
var turnaround_multi := 2.0 # How much acceleration is multiplied with when velocity and input does not match up
var max_speed_acceleration_divi := 1.5 # How much acceleration is divided with (along with how much over the "max" is) when over "max" speed

var _body: CharacterBody2D

# Just set all the public variables
func _init(
    character_body: CharacterBody2D,
    max_speed_: float,
    acceleration_force_: float,
    decceleration_force_: float,
    air_control_multi_: float,
    air_friction_multi_: float,
    max_speed_friction_multi_: float,
    turnaround_multi_: float,
    max_speed_acceleration_divi_: float,
    ):
    _body = character_body
    # If the given function property is not null, set the variable to the property
    if max_speed_: max_speed = max_speed_
    if acceleration_force_: acceleration_force = acceleration_force_
    if decceleration_force_: decceleration_force = decceleration_force_
    if air_control_multi_: air_control_multi = air_control_multi_
    if air_friction_multi_: air_friction_multi = air_friction_multi_
    if max_speed_friction_multi_: max_speed_friction_multi = max_speed_friction_multi_
    if turnaround_multi_: turnaround_multi = turnaround_multi_
    if max_speed_acceleration_divi_: max_speed_acceleration_divi = max_speed_acceleration_divi_

func update(delta: float, direction: float):
    # If actually pressing keys
    var should_accelerate = abs(direction) > 0
    if should_accelerate:
        _accelerate(delta, direction)
    
    var should_deccelerate = abs(_body.velocity.x) > max_speed && sign(direction) == sign(_body.velocity.x) && _body.is_on_floor()

    if !should_accelerate || should_deccelerate:
        _deccelerate(delta, direction)

func _accelerate(delta: float, direction: float):
    var accel = acceleration_force * delta
    if not _body.is_on_floor():
        accel *= air_control_multi

    # If trying to move in the opposite direction, apply a boost to the acceleration
    if sign(direction) != sign(_body.velocity.x):
        accel *= turnaround_multi

    # If moving faster than the max speed and moving in the same direction, you should
    # accelerate slower
    if abs(_body.velocity.x) > max_speed && sign(direction) == sign(_body.velocity.x):
        _body.velocity.x += accel * direction / ((abs(max_speed) - abs(_body.velocity.x)) * max_speed_acceleration_divi)
        return
        
    _body.velocity.x = move_toward(_body.velocity.x, max_speed * direction, accel)

func _deccelerate(delta: float, direction: float):
    var deccel = decceleration_force * delta
    if not _body.is_on_floor():
        deccel *= air_friction_multi

    # If moving faster than the max speed, you should deccelerate slower
    if abs(_body.velocity.x) > max_speed && sign(direction) == sign(_body.velocity.x):
        deccel *= max_speed_friction_multi

    _body.velocity.x = move_toward(_body.velocity.x, 0, deccel)

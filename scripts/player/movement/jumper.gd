class_name Jumper
# PUBLIC
var jump_force := 250.0 # How much force is applied when jumping
var jump_release_multi := 0.35 # When you release jump after a jump, how much should y velocity be multiplied by
var coyote_time := 0.175 # For how long can you jump after walked off a platform
var jump_buffer_time := 0.2 # For how long can you jump before touching a platform
var walljump_force := Vector2(300.0, 200.0)

# MUTABLE
var _coyote_timer := 0.0 # The timer related to coyote_time
var _wall_coyote_timer := 0.0 # The timer related to coyote_time
var _jump_buffer := 0.0 # The timer related to jump_buffer_time

var _can_release_jump := false # If you can release jump after the jump or not, turns false when y velocity is more than zero and when you release jump
var _current_wall_normal = 0

# EXTERNAL REFERENCES
var _body: CharacterBody2D # The physics body the movement is applied to

func _init(
    character_body: CharacterBody2D,
    jump_force_: float, 
    jump_release_multi_: float, 
    coyote_time_: float,
    jump_buffer_time_: float,
    walljump_force_: Vector2
    ):
    _body = character_body
    # If the given function property is not null, set the variable to the property
    if jump_force_: jump_force = jump_force_
    if jump_release_multi_: jump_release_multi = jump_release_multi_
    if coyote_time_: coyote_time = coyote_time_
    if jump_buffer_time_: jump_buffer_time = jump_buffer_time_
    if walljump_force_: walljump_force = walljump_force_

# input is of type res://scripts/player/input.gd/InputAction
func update(delta: float, input):
    _jump_timers(delta, input)
    _handle_jump_release(input)

    # If grounded and pressed jump, then jump
    var should_jump := _coyote_timer < coyote_time && _jump_buffer < jump_buffer_time
    if should_jump: 
        jump(Vector2.UP * jump_force)

    var should_walljump := _wall_coyote_timer < coyote_time && _jump_buffer < jump_buffer_time
    if should_walljump:
        jump(Vector2(_current_wall_normal, -1) * walljump_force)
        
func _jump_timers(delta: float, input):
    _jump_buffer += delta
    _coyote_timer += delta
    _wall_coyote_timer += delta
    if input.just_pressed():
        _jump_buffer = 0.0

    if _body.is_on_floor(): 
        _coyote_timer = 0.0

    if _body.is_on_wall():
        _wall_coyote_timer = 0.0
        _current_wall_normal = _body.get_wall_normal().x

    if _body.velocity.y > 0.0: 
        _can_release_jump = false

func _handle_jump_release(input):
    # If releasing jump while ascending, multiply the y velocity by a small number
    if _can_release_jump && input.just_released():
        _body.velocity.y *= jump_release_multi 
        _can_release_jump = false

# Public function just in cas
func jump(jump_force: Vector2):
    # Reset timers
    _coyote_timer = coyote_time
    _wall_coyote_timer = coyote_time
    _jump_buffer = jump_buffer_time
    _can_release_jump = true

    # Actually jump
    _body.velocity += jump_force 

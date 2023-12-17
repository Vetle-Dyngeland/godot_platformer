class_name Player extends CharacterBody2D

@export_category("Horizontal Movement")
@export var max_speed := 100.0 # Max x speed
@export var acceleration_force := 500.0 # Force applied when accelerating
@export var decceleration_force := 500.0 # Force applied when deccelerating
@export var air_control_multi := 0.7 # How much acceleration is multiplied with when in the air
@export var air_friction_multi := 0.1 # How much decceleration is multiplied with when in the air
@export var turnaround_multi := 2.0 # How much acceleration is multiplied with when velocity and input does not match up

@export_category("Jumper")
@export var jump_force := 250.0 
@export var jump_release_multi := 0.35 
@export var coyote_time := 0.175 
@export var jump_buffer_time := 0.2


@export_category("Gravity")
@export var held_down_gravity_multi := 1.5 # When you hold "move_down", how much gravity is multiplied by
@export var terminal_fall_velocity := 400.0 # Max speed you can fall
@export var held_down_fall_velocity_multi := 1.5 # How much terminal velocity increases when you hold "move_down"

var horizontal_movement = HorizontalMovement.new(
    $".", 
    max_speed,
    acceleration_force,
    decceleration_force,
    air_control_multi,
    air_friction_multi,
    turnaround_multi
)

var jumper = Jumper.new(
    $".",
    jump_force,
    jump_release_multi,
    coyote_time,
    jump_buffer_time
)

var gravity = Gravity.new(
    $".",
    held_down_gravity_multi,
    terminal_fall_velocity,
    held_down_fall_velocity_multi
)

func _physics_process(delta: float) -> void:
    horizontal_movement.update(delta)
    jumper.update(delta)
    gravity.update(delta)

    move_and_slide()

class InputAction:
    enum InputActionType { Button, Axis, Vector }

    # Depending on _type this could be one of two things: 
    # For a button this is an array of three bools, where index 0 is held, 1 is just pressed and 2 is just released
    # For Vector and axis this is an array of two values, where index 0 is right now and 1 is thethe  previous frame
    var _output: Array

    var _button_name := ""
    var _axis_name := ["", ""]
    var _vector_name := ["", "", "", ""]
    var _type: InputActionType

    func _init(name):
        var button := typeof("")
        var array := typeof([])
        
        # Set the type of the input action
        match typeof(name):
            button: _type = InputActionType.Button
            array: 
                match len(name):
                    2: _type = InputActionType.Axis
                    4: _type = InputActionType.Vector
                    _: print(str("An array of length ", len(name), " cannot be parsed into input!"))
            _: print(str("A variable of _type: ", name, " = ", typeof(name), " cannot be parsed into input!"))

        # Set the output as well as the name to avoid future errors
        match _type:
            InputActionType.Button: 
                _button_name = name
                _output = [false, false, false]

            InputActionType.Axis: 
                _axis_name = name
                _output = [0, 0]
            InputActionType.Vector: 
                _vector_name = name
                _output = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]

    # Seperate update functions depending on which type of input action this is
    func update():
        match _type:
            InputActionType.Button: _update_button()
            InputActionType.Axis: _update_axis()
            InputActionType.Vector: _update_vector()

    func _update_button():
        _output = [
            Input.is_action_pressed(_button_name),
            Input.is_action_just_pressed(_button_name),
            Input.is_action_just_released(_button_name),
        ]

    func _update_axis():
        _output[1] = _output[0]
        _output[0] = Input.get_axis(_axis_name[0], _axis_name[1])

    func _update_vector():
        if _output[0]: _output[1] = _output[0]

        # Two axises instead of get_vector to stop them getting normalized
        var x = Input.get_axis(_vector_name[0], _vector_name[1])
        var y = Input.get_axis(_vector_name[2], _vector_name[3])
        
        _output[0] = Vector2(x, y)

    # Only makes sense if the type is not a button, so it should be invalid for all other types
    func get_previous_frame(): 
        match _type:
            InputActionType.Button: return null
            _: return _output[1]

    # Get input makes sense in all contexts
    func get_input(): return _output[0]

    # If you know the type and just want the input
    func get_raw_input_array(): return _output

    # Held function only makes sense if the type is a button, so it should be invalid for all other types
    func held():
        match _type:
            InputActionType.Button: return _output[0]
            _: return null
    # Same applies here 
    func just_pressed():
        match _type:
            InputActionType.Button: return _output[1]
            _: return null
    # As well as here
    func just_released():
        match _type:
            InputActionType.Button: return _output[2]
            _: return null
    
class Gravity:
    # PUBLIC
    var held_down_gravity_multi := 1.5 # When you hold "move_down", how much gravity is multiplied by
    var terminal_fall_velocity := 400.0 # Max speed you can fall
    var held_down_fall_velocity_multi := 1.5 # How much terminal velocity increases when you hold "move_down"

    var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
    var _body: CharacterBody2D # The physics body the movement is applied to
    var _input = InputAction.new(["move_up", "move_down"])

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

    func update(delta: float):
        if _body.is_on_floor(): return # Gravity shouldnt be applied when you're on the floor

        var gravity_force = _gravity * delta
        var terminal_velocity = terminal_fall_velocity # Just a mutable clone

        if _input.get_input() > 0.0: # If move_down is held
            gravity_force *= held_down_gravity_multi
            terminal_velocity *= held_down_fall_velocity_multi

        _body.velocity.y += gravity_force
        if _body.velocity.y > terminal_velocity: # If falling faster than allowed, dont
            _body.velocity.y = terminal_velocity

class Jumper:
    # PUBLIC
    var jump_force := 250.0 # How much force is applied when jumping
    var jump_release_multi := 0.35 # When you release jump after a jump, how much should y velocity be multiplied by
    var coyote_time := 0.175 # For how long can you jump after walked off a platform
    var jump_buffer_time := 0.2 # For how long can you jump before touching a platform

    # MUTABLE
    var _coyote_timer := 0.0 # The timer related to coyote_time
    var _jump_buffer := 0.0 # The timer related to jump_buffer_time
    var _can_release_jump := false # If you can release jump after the jump or not, turns false when y velocity is more than zero and when you release jump

    # EXTERNAL REFERENCES
    var _input = InputAction.new("jump")
    var _body: CharacterBody2D # The physics body the movement is applied to

    func _init(
        character_body: CharacterBody2D,
        jump_force_: float, 
        jump_release_multi_: float, 
        coyote_time_: float,
        jump_buffer_time_: float
        ):
        _body = character_body
        # If the given function property is not null, set the variable to the property
        if jump_force_: jump_force = jump_force_
        if jump_release_multi_: jump_release_multi = jump_release_multi_
        if coyote_time_: coyote_time = coyote_time_
        if jump_buffer_time_: jump_buffer_time = jump_buffer_time_

    func update(delta: float):
        _jump_timers(delta)
        _handle_jump_release()

        # If grounded and pressed jump, then jump
        var should_jump = _coyote_timer < coyote_time && _jump_buffer < jump_buffer_time
        if should_jump: 
            jump(Vector2(0, -jump_force))
            
    func _jump_timers(delta: float):
        _jump_buffer += delta
        _coyote_timer += delta
        if _input.just_pressed():
            _jump_buffer = 0.0

        if _body.is_on_floor(): 
            _coyote_timer = 0.0

        if _body.velocity.y > 0.0: 
            _can_release_jump = false

    func _handle_jump_release():
        # If releasing jump while ascending, multiply the y velocity by a small number
        if _can_release_jump && _input.just_released():
            _body.velocity.y *= jump_release_multi 
            _can_release_jump = false

    # Public function just in cas
    func jump(jump_force: Vector2):
        # Reset timers
        _coyote_timer = coyote_time
        _jump_buffer = jump_buffer_time
        _can_release_jump = true

        # Actually jump
        _body.velocity += jump_force 

class HorizontalMovement:
    var max_speed := 100.0 # Max x speed
    var acceleration_force := 500.0 # Force applied when accelerating
    var decceleration_force := 500.0 # Force applied when deccelerating
    var air_control_multi := 0.7 # How much acceleration is multiplied with when in the air
    var air_friction_multi := 0.1 # How much decceleration is multiplied with when in the air
    var turnaround_multi := 2.0 # How much acceleration is multiplied with when velocity and input does not match up

    var _input = InputAction.new(["move_left", "move_right"])
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

    func update(delta: float):
        _input.update()
        var direction = _input.get_input()

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

class_name Player extends CharacterBody2D

var movement = PlayerMovement.new($".")

func _process(_delta: float) -> void:
    movement.process()

func _physics_process(delta: float) -> void:
    movement.physics_process(delta)

class InputAction:
    enum InputActionType {
        Button,
        Axis,
        Vector
    }

    var output
    var _button_name: String
    var _axis_name := ["", ""]
    var _vector_name := ["", "", "", ""]
    var _type: InputActionType

    func _init(name):
        var button := typeof("")
        var array := typeof([])
        match typeof(name):
            button: _type = InputActionType.Button
            array: 
                match len(name):
                    2: _type = InputActionType.Axis
                    4: _type = InputActionType.Vector
                    _: print(str("An array of length ", len(name), " cannot be parsed into input!"))
            _: print(str("A variable of _type: ", name, " = ", typeof(name), " cannot be parsed into input!"))

        match _type:
            InputActionType.Button: 
                _button_name = name
                output = [false, false, false]

            InputActionType.Axis: 
                _axis_name = name
                output = [0, 0]
            InputActionType.Vector: 
                _vector_name = name
                output = [Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO]

    func update():
        match _type:
            InputActionType.Button: _update_button()
            InputActionType.Axis: _update_axis()
            InputActionType.Vector: _update_vector()

    func _update_button():
        output = [
            Input.is_action_pressed(_button_name),
            Input.is_action_just_pressed(_button_name),
            Input.is_action_just_released(_button_name),
        ]

    func _update_axis():
        output[1] = output[0]
        output[0] = Input.get_axis(_axis_name[0], _axis_name[1])

    func _update_vector():
        if output[0]: output[1] = output[0]

        # Two axises to stop them getting normalized
        var x = Input.get_axis(_vector_name[0], _vector_name[1])
        var y = Input.get_axis(_vector_name[2], _vector_name[3])
        
        output[0] = Vector2(x, y)

class PlayerMovement:
    var jump_force := 250
    var held_down_gravity_multi := 1.5
    var terminal_fall_velocity := 400.0
    var held_down_fall_velocity_multi := 1.5
    var jump_release_multi := 0.35
    var coyote_time := 0.175
    var jump_buffer_time := 0.2

    var max_speed := 100.0
    var acceleration_force := 500.0
    var decceleration_force := 500.0
    var air_control_multi := 0.7
    var air_friction_multi := 0.1
    var turnaround_multi := 2
    var body: CharacterBody2D

    var movement_input = InputAction.new(["move_left", "move_right", "move_up", "move_down"])
    var jump_input = InputAction.new("jump")

    var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

    var coyote_timer := 0.0
    var jump_buffer := 0.0
    var can_release_jump := false

    func _init(character_body: CharacterBody2D):
        body = character_body

    func process():
        movement_input.update()
        jump_input.update()

    func physics_process(delta: float):
        handle_gravity(delta)
        handle_walking(delta)
        handle_jumping(delta)
        body.move_and_slide()

    func handle_gravity(delta: float):
        if body.is_on_floor(): return

        var gravity_force = gravity * delta
        var terminal_velocity = terminal_fall_velocity
        if movement_input.output[1].y > 0.0:
            gravity_force *= held_down_gravity_multi
            terminal_velocity *= held_down_fall_velocity_multi

        body.velocity.y += gravity_force
        if body.velocity.y > terminal_velocity:
            body.velocity.y = terminal_velocity

    func handle_walking(delta: float):
        var direction = movement_input.output[0].x

        if abs(direction) > 0:
            accelerate(delta, direction)
            return

        deccelerate(delta)

    func accelerate(delta: float, direction: float):
        var accel = acceleration_force * delta
        if not body.is_on_floor():
            accel *= air_control_multi

        if sign(direction) != sign(body.velocity.x):
            accel *= turnaround_multi

        body.velocity.x = move_toward(body.velocity.x, max_speed * direction, accel) 

    func deccelerate(delta: float):
        var deccel = decceleration_force * delta
        if not body.is_on_floor():
            deccel *= air_friction_multi

        body.velocity.x = move_toward(body.velocity.x, 0, deccel)

    func handle_jumping(delta: float):
        jump_timers(delta)
        if can_release_jump && !jump_input.output[0]:
            body.velocity.y *= jump_release_multi

        if coyote_timer < coyote_time && jump_buffer < jump_buffer_time:
            coyote_timer = coyote_time
            jump_buffer = jump_buffer_time
            body.velocity.y -= jump_force
            can_release_jump = true

    func jump_timers(delta: float):
        jump_buffer += delta
        coyote_timer += delta
        if jump_input.output[1]:
            jump_buffer = 0.0

        if body.is_on_floor():
            coyote_timer = 0.0

        if body.velocity.y > 0.0: can_release_jump = false

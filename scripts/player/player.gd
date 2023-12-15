extends CharacterBody2D

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
    var type: InputActionType

    func _init(name):
        var button := typeof("")
        var array := typeof([])
        match typeof(name):
            button: type = InputActionType.Button
            array: 
                match len(name):
                    2: type = InputActionType.Axis
                    4: type = InputActionType.Vector
                    _: print(str("An array of length ", len(name), " cannot be parsed into input!"))
            _: print(str("A variable of type: ", name, " = ", typeof(name), " cannot be parsed into input!"))

        match type:
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
        match type:
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
        output[0] = Input.get_vector(_vector_name[0], _vector_name[1], _vector_name[2], _vector_name[3])

@export var held_down_gravity_multi := 1.5
@export var jump_force := 40.0
@export var terminal_fall_velocity := 10.0

@export var max_speed := 100.0
@export var acceleration_force := 500.0
@export var decceleration_force := 500.0
@export var air_control_multi := 0.7
@export var air_friction_multi := 0.1

var movement_input = InputAction.new(["move_left", "move_right", "move_up", "move_down"])
var jump_input = InputAction.new("jump")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(_delta: float):
    movement_input.update()
    jump_input.update()

func _physics_process(delta: float):
    handle_gravity(delta)
    handle_walking(delta)
    move_and_slide()

func handle_gravity(delta: float):
    var gravity_force = gravity * delta
    if movement_input.output[1].y < 0.0:
        gravity_force *= held_down_gravity_multi
    if not is_on_floor():
        velocity.y += gravity_force

func handle_walking(delta: float):
    var direction = movement_input.output[0].x

    if abs(direction) > 0:
        accelerate(delta, direction)
    if abs(direction) == 0 || sign(direction) != sign(velocity.x): deccelerate(delta)

func accelerate(delta: float, direction: float):
    var accel = acceleration_force * delta
    if not is_on_floor():
        accel *= air_control_multi

    velocity.x = move_toward(velocity.x, max_speed * direction, accel) 

func deccelerate(delta: float):
    var deccel = decceleration_force * delta
    if not is_on_floor():
        deccel *= air_friction_multi

    velocity.x = move_toward(velocity.x, 0, deccel)

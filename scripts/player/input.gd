class_name PlayerInputs
var horizontal_input = InputAction.new(["move_left", "move_right"])
var vertical_input = InputAction.new(["move_up", "move_down"])
var jump_input = InputAction.new("jump")

func update():
    horizontal_input.update()
    vertical_input.update()
    jump_input.update()


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

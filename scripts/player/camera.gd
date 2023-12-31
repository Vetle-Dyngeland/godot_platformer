class_name PlayerCamera

var lookahead_time: float
var lookahead_ignore_y: bool
var smoothing_amount: int
var smoothing_ignore_y: bool
var camera_scaling: float

var root: Node

var player: CharacterBody2D
var _camera: Camera2D = null

var _smoothing_positions := []

func _init(
    root_: Node,
    player_: CharacterBody2D,
    lookahead_time_ := 0.2,
    lookahead_ignore_y_ := false,
    smoothing_amount_ := 12,
    smoothing_ignore_y_ := false,
    camera_scaling_ := 0.5
):
    root = root_
    player = player_
    lookahead_time = lookahead_time_
    lookahead_ignore_y = lookahead_ignore_y_
    smoothing_amount = smoothing_amount_
    smoothing_ignore_y = smoothing_ignore_y_
    camera_scaling = camera_scaling_

func update(delta: float):
    # If the camera does not exist, create a new one
    if !_camera: 
        reset()

    update_smoothing(delta)
    move_camera(delta)

func reset():
    _set_camera() # Get/create the camera
    _reset_mutable() # Reset the smoothing and such
    _set_camera_options() # Set the options in the camera itself, fex. the position 

func _set_camera():
    # Searches each node to check if it's a camera
    for child in get_all_children(root):
        if child is Camera2D: 
            # If the child is a camera, set the _camera and escape the function
            _camera = child
            return

    _camera = Camera2D.new()
    root.add_child(_camera)

func _set_camera_options():
    _camera.position = player.position # Set the initial position
    _camera.zoom = Vector2.ONE * camera_scaling

func _reset_mutable():
    _smoothing_positions = []

func get_all_children(node, arr := []):
    arr.append(node)
    for child in node.get_children():
        arr = get_all_children(child, arr)
    return arr

func update_smoothing(delta: float):
    # Add the current position
    _smoothing_positions.append(_get_position_and_lookahead(delta)) 

    # Remove (most often) the last position so it only averages recent positions
    while len(_smoothing_positions) > smoothing_amount:
        _smoothing_positions.remove_at(0)

func move_camera(delta: float):
    var final_pos := Vector2.ZERO
    for position in _smoothing_positions:
        final_pos += position

    if final_pos != Vector2.ZERO:
        final_pos /= len(_smoothing_positions) # Get the average
    else: # If the smoothing amount is 0
        final_pos = _get_position_and_lookahead(delta)

    if smoothing_ignore_y:
        final_pos.y = player.position.y

    _camera.position = final_pos

# Gets the position with lookahead
func _get_position_and_lookahead(delta: float) -> Vector2:
    var new_position := player.position
    var lookahead := player.velocity * delta * lookahead_time
    if lookahead_ignore_y: 
        lookahead.y = 0.0
    new_position += lookahead
    return new_position

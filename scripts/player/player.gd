class_name Player extends CharacterBody2D

@export_category("Horizontal Movement")
@export var max_speed := 200.0 # Max x speed
@export var acceleration_force := 1000.0 # Force applied when accelerating
@export var decceleration_force := 1000.0 # Force applied when deccelerating
@export var air_control_multi := 0.7 # How much acceleration is multiplied with when in the air
@export var air_friction_multi := 0.1 # How much decceleration is multiplied with when in the air
@export var max_speed_friction_multi := 0.5 # How much decceleration is multiplied with when above max speed and moving the same direction
@export var turnaround_multi := 2.0 # How much acceleration is multiplied with when velocity and input does not match up
@export var max_speed_acceleration_divi := 1.5 # How much acceleration is divided with (along with how much over the "max" is) when over "max" speed

@export_category("Jumper")
@export var jump_force := 350.0
@export var walljump_force := Vector2(250.0, 350.0)
@export var jump_release_multi := 0.35
@export var coyote_time := 0.175
@export var jump_buffer_time := 0.2

@export_category("Gravity")
@export var held_down_gravity_multi := 1.5 # When you hold "move_down", how much gravity is multiplied by
@export var terminal_fall_velocity := 400.0 # Max speed you can fall
@export var held_down_fall_velocity_multi := 1.5 # How much terminal velocity increases when you hold "move_down"

@export_category("Camera")
@export var lookahead_time := 4 # How far ahead should the camera look ahead of the player
@export var lookahead_ignore_y := true # Should the lookahead ignore the y position?
@export var smoothing_amount := 12 # How many previous positions should be averaged to calculate the new position
@export var smoothing_ignore_y := true # Should the smoothing ignore the y?
@export var camera_scaling := 0.5 # How zoomed should the camera be?

var input: PlayerInputs
var horizontal_movement: HorizontalMovement
var jumper: Jumper
var gravity: Gravity
var visuals: PlayerVisuals
var weapons: WeaponHolder
var camera: PlayerCamera

# Create components
func _ready() -> void:
    input = PlayerInputs.new();

    horizontal_movement = HorizontalMovement.new(
        $".",
        max_speed,
        acceleration_force,
        decceleration_force,
        air_control_multi,
        air_friction_multi,
        max_speed_friction_multi,
        turnaround_multi,
        max_speed_acceleration_divi
    )

    jumper = Jumper.new(
        $".",
        jump_force,
        jump_release_multi,
        coyote_time,
        jump_buffer_time,
        walljump_force
    )

    gravity = Gravity.new(
        $".",
        held_down_gravity_multi,
        terminal_fall_velocity,
        held_down_fall_velocity_multi
    )

    visuals = PlayerVisuals.new(
        get_node_of_type(Sprite2D),
    )

    weapons = WeaponHolder.new($"./Sprite/Weapon Holder")

    camera = PlayerCamera.new(
        get_tree().root.get_child(0),
        $".",
        lookahead_time,
        lookahead_ignore_y,
        smoothing_amount,
        smoothing_ignore_y,
        camera_scaling
    )

func get_node_of_type(type):
    for child in get_children():
        if typeof(child) == typeof(type):
            return child


func _process(delta: float) -> void:
    input.update()
    visuals.update(input.horizontal_input.get_input())
    weapons.update(input.attack_input)
    camera.update(delta)

func _physics_process(delta: float) -> void:
    horizontal_movement.update(delta, input.horizontal_input.get_input())
    jumper.update(delta, input.jump_input)
    gravity.update(delta, input.vertical_input.get_input())

    move_and_slide()

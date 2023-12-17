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

var input = PlayerInputs.new();

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

func _process(_delta: float) -> void:
    input.update()   

func _physics_process(delta: float) -> void:
    horizontal_movement.update(delta, input.horizontal_input.get_input())
    jumper.update(delta, input.jump_input)
    gravity.update(delta, input.vertical_input.get_input())

    move_and_slide()

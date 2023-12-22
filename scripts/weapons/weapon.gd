class_name Weapon extends Node2D

@export var damage := 10.0
@export var attack_rate := 2
@export var keep_attacking_while_held := false
@export var position_offset := Vector2(7, -2)

var _anim_player: AnimationPlayer = null

var attacking = false

func _init():
    #position = position_offset
    pass

func _get_animation_player():
    for child in get_children():
        if child is AnimationPlayer:
            _anim_player = child
            return

    # If the function above did not return, it didn't get the player
    print("Could not get animation player")

func update(input) -> void:
    # For some reason, the weapon cannot find the animation player in _init()
    if !_anim_player: _get_animation_player()

    if !_anim_player.is_playing() && attacking:
        _anim_player.speed_scale = 1
        _anim_player.play("weapons/RESET")
        attacking = false

    if _should_attack(input):
        attack()

func _should_attack(input) -> bool:
    return !attacking && ((keep_attacking_while_held && input.held()) || input.just_pressed())

func attack():
    attacking = true
    _anim_player.play("weapons/sword_attack")
    _anim_player.speed_scale = _anim_player.current_animation_length / (1.0 / attack_rate)


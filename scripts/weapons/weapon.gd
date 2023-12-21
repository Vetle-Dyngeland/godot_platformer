class_name Weapon extends Node2D

@export var damage := 10.0
@export var attack_rate := 2
@export var keep_attacking_while_held := false

var attacking = false

func _process(_delta: float) -> void:
    if should_attack():
        attack()

func should_attack() -> bool:
    if keep_attacking_while_held:
        return Input.is_action_pressed("attack", false)
    else: return Input.is_action_just_pressed("attack", false)

func attack():
    attacking = true
    attacking = false

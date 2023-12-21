class_name Weapon extends Node2D

@export var damage := 10.0
@export var attack_rate := 2
@export var keep_attacking_while_held := false

var attacking = false

func _init():
    pass   

func update(input) -> void:
    if _should_attack(input): attack()

func _should_attack(input) -> bool:
    return (keep_attacking_while_held && input.held()) || input.just_pressed()
    
func attack():
    attacking = true

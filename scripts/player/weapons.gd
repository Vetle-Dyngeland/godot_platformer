class_name WeaponHolder

var holder: Node

var _inventory := [preload("res://scenes/sword.tscn")]
var _held_weapon_index: int = 0

var _current

func _init(holder_: Node) -> void:
    holder = holder_

# Input is of type InputAction, defined in player/input.gd
func update(input):
    # If not holding a weapon, don't update anything
    if !_held_weapon_index && _held_weapon_index != 0: return
    if !_current:
        swap_weapon(_held_weapon_index)

    _current.update(input)

func swap_weapon(new_index: int):
    _held_weapon_index = new_index

    _current = _inventory[_held_weapon_index].instantiate()
    holder.add_child(_current)
    holder.position = _current.position_offset

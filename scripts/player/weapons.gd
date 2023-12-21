class_name WeaponHolder

var _inventory := []
var _held_weapon_index: int


func _init() -> void:
    pass

# Input is of type InputAction, defined in player/input.gd
func update(input):
    # If not holding a weapon, don't update anything
    if !_held_weapon_index: return
    _inventory[_held_weapon_index].update(input)

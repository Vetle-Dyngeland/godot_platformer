class_name PlayerVisuals

var _sprite: Sprite2D

func _init(sprite: Sprite2D):
    _sprite = sprite

func update(input: float) -> void:
    # If moved and changed direction, flip the sprite
    var should_flip_sprite = input != 0 && input < 0 != _sprite.flip_h

    if should_flip_sprite:
        _flip_sprite(input < 0)

func _flip_sprite(value: bool):
    _sprite.flip_h = value

    # First, only mirror positions of the top node to avoid double flipping
    for child in _sprite.get_children():
        if !(child is Node2D): continue
        child.position.x = -child.position.x

    # But flip sprites of all children, since it doesnt apply to further children
    for child in get_all_children(_sprite):
        if !child is Sprite2D: continue
        child.flip_h = value

func get_all_children(node, arr := []):
    arr.append(node)
    for child in node.get_children():
        arr = get_all_children(child, arr)
    return arr

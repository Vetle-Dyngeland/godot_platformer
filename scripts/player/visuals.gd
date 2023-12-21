class_name PlayerVisuals

var _sprite: Sprite2D

func _init(sprite: Sprite2D):
    _sprite = sprite

func update(input: float) -> void:
    var should_flip_sprite = input < 0 != _sprite.flip_h

    if should_flip_sprite:
        _flip_sprite(input)
    
func _flip_sprite(input: float):
    _sprite.flip_h = input < 0

    for child in _sprite.get_children():
        if !(child is Node2D): continue

        child.position.x = -child.position.x

        if !(child is Sprite2D): continue
        child.flip_h = input < 0


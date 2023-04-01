extends Area2D

class_name Bullet

const ITEM_OBJ = preload("res://src/Item.tscn")

var _velocity = Vector2.ZERO # 速度.
var _accel = Vector2.ZERO # 加速度.

## 消滅.
func vanish() -> void:
	queue_free()

## アイテム登場.
func add_item() -> void:
	var item = ITEM_OBJ.instantiate()
	Common.get_layer("main").add_child(item)
	var d = 40
	var deg = randf_range(90-d, 90+d)
	var speed = 300
	item.setup(position, deg, speed)

## 速度を設定する.
func set_velocity(deg:float, speed:float) -> void:
	var rad = deg_to_rad(deg)
	_velocity.x = cos(rad) * speed
	_velocity.y = -sin(rad) * speed

## 加速度を設定する.
func set_accel(ax:float, ay:float) -> void:
	_accel.x = ax
	_accel.y = ay

## 更新
func _physics_process(delta: float) -> void:
	_velocity += _accel
	position += _velocity * delta
	
	if Common.is_in_screen(position) == false:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is Shot:
		if area.is_erase_bullet():
			add_item()
			vanish()

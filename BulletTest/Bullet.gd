extends Area2D

class_name Bullet

var _velocity = Vector2.ZERO # 速度.
var _accel = Vector2.ZERO # 加速度.

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
	

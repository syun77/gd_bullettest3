extends Area2D

class_name Player

const SHOT_OBJ = preload("res://src/shot/Shot.tscn")
const SHOT2_OBJ = preload("res://src/shot/Shot2.tscn")

@onready var _spr = $Sprite

var _shot_timer = 0.0
var _shot_cnt = 0

func _physics_process(delta: float) -> void:
	_shot(delta)
	
	var v = Vector2()
	if Input.is_action_pressed("ui_left"):
		v.x += -1
	if Input.is_action_pressed("ui_up"):
		v.y += -1
	if Input.is_action_pressed("ui_right"):
		v.x += 1
	if Input.is_action_pressed("ui_down"):
		v.y += 1
	
	v = v.normalized()
	position += 300 * v * delta

func _shot(delta:float) -> void:
	_shot_timer -= delta
	if Input.is_action_pressed("ui_accept") == false:
		return
	if _shot_timer > 0:
		return
	
	_shot_timer = 0.04
	_shot_cnt += 1
	for i in [-1, 0, 1]:
		var shot = SHOT_OBJ.instantiate()
		var pos = position
		pos.y -= 8
		pos += Vector2(8, 0) * i
		if _shot_cnt%2 == 0:
			pos.y -= 16
		var deg = 90 + randf_range(0, 10) * i * -1
		Common.get_layer("shot").add_child(shot)
		shot.setup(pos, deg, 1500)

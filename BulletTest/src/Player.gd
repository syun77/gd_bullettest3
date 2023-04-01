extends Node2D

class_name Player

const ShotObj = preload("res://src/shot/Shot.tscn")
const Shot2Obj = preload("res://src/shot/Shot2.tscn")

var _shot_timer = 0.0
var _shot_cnt = 0

func _physics_process(delta: float) -> void:
	_shot_timer += delta
	
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

extends Area2D

class_name Player

const SHOT_OBJ = preload("res://src/shot/Shot.tscn")
const SHOT2_OBJ = preload("res://src/shot/Shot2.tscn")
const ABSORB_OBJ = preload("res://src/particle/Absorb.tscn")

const TIMER_BARRIER_HIT = 1.0

@onready var _spr = $Sprite
@onready var _barrier_spr = $Barrier/Sprite

var _shot_timer = 0.0
var _shot_cnt = 0
var _absorb_timer = 0.0
var _absorb_scale_base = Vector2.ONE

func _ready() -> void:
	_absorb_scale_base = _barrier_spr.scale

func _physics_process(delta: float) -> void:
	
	_shot(delta)
	
	_update_absorb(delta)
	
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

func _update_absorb(delta:float) -> void:
	if _absorb_timer <= 0.0:
		return
	_absorb_timer -= delta
	var rate = _absorb_timer / TIMER_BARRIER_HIT
	rate = elastic_in(rate)
	if rate > 0.9:
		rate = 0.9
	_barrier_spr.scale = _absorb_scale_base * (1.0 - rate * 0.1)
	
# 弾力関数
const ELASTIC_AMPLITUDE = 1.0
const ELASTIC_PERIOD = 0.4
func elastic_in(t:float) -> float:
	t -= 1
	return -(ELASTIC_AMPLITUDE * pow(2, 10 * t) * sin( (t - (ELASTIC_PERIOD / (2 * PI) * asin(1 / ELASTIC_AMPLITUDE))) * (2 * PI) / ELASTIC_PERIOD))
func elastic_out(t:float) -> float:
	return (ELASTIC_AMPLITUDE * pow(2, -10 * t) * sin((t - (ELASTIC_PERIOD / (2 * PI) * asin(1 / ELASTIC_AMPLITUDE))) * (2 * PI) / ELASTIC_PERIOD) + 1)
func elastic_in_out(t:float) -> float:
	if (t < 0.5):
		t -= 0.5
		return -0.5 * (pow(2, 10 * t) * sin((t - (ELASTIC_PERIOD / 4)) * (2 * PI) / ELASTIC_PERIOD))
	else:
		t -= 0.5
		return pow(2, -10 * t) * sin((t - (ELASTIC_PERIOD / 4)) * (2 * PI) / ELASTIC_PERIOD) * 0.5 + 1

func _on_barrier_area_entered(area: Area2D) -> void:
	if area is Bullet:
		_absorb_timer = TIMER_BARRIER_HIT
		var absorb = ABSORB_OBJ.instantiate()
		absorb.position = area.position
		Common.get_layer("particle").add_child(absorb)
		area.vanish()

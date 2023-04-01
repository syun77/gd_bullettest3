extends Area2D

class_name Player

const SHOT_OBJ = preload("res://src/shot/Shot.tscn")
const SHOT2_OBJ = preload("res://src/shot/Shot2.tscn")
const ABSORB_OBJ = preload("res://src/particle/Absorb.tscn")

const TIMER_BARRIER_HIT = 1.0
const TIMER_LASER = (0.016 * 16)
const TIMER_MOVE = 0.3

@onready var _spr = $Sprite
@onready var _barrier = $Barrier
@onready var _barrier_spr = $Barrier/Sprite
@onready var _barrier_col = $Barrier/CollisionShape2D
@onready var _option = $Option

var _shot_timer = 0.0
var _shot_cnt = 0
var _absorb_timer = 0.0
var _absorb_scale_base = Vector2.ONE
var _laser_timer = 0.0
var _move_timer = 0.0
var _spr_base_sc = Vector2.ONE

func _ready() -> void:
	_absorb_scale_base = _barrier_spr.scale
	_spr_base_sc = _spr.scale

func _is_barrier() -> bool:
	if Common.is_absorb:
		return true
	if Common.is_reflect:
		return true
	
	return false

func _physics_process(delta: float) -> void:
	
	if _is_barrier():
		_barrier.visible = true
		_barrier_col.disabled = false
	else:
		_barrier.visible = false
		_barrier_col.disabled = true
	
	_shot(delta)
	
	_update_absorb(delta)
	
	_update_option(delta)
	
	_update_anim(delta)
	
	var v = Vector2()
	if Input.is_action_pressed("ui_left"):
		v.x += -1
		_move_timer += delta * 3
	if Input.is_action_pressed("ui_up"):
		v.y += -1
	if Input.is_action_pressed("ui_right"):
		v.x += 1
		_move_timer += delta * 3
	if Input.is_action_pressed("ui_down"):
		v.y += 1
	
	v = v.normalized()
	position += 300 * v * delta

func _shot(delta:float) -> void:
	_shot_timer -= delta
	
	if _laser_timer > 0:
		_shot_cnt += 1
		if _shot_cnt%2 == 0:
			_laser_timer -= delta
			_shot_laser()
		return
		
	if Input.is_action_just_pressed("ui_cancel"):
		# 力の解放.
		_laser_timer = TIMER_LASER
		_shot_laser()
		return
		
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
		
func _shot_laser() -> void:
	var shot = SHOT2_OBJ.instantiate()
	Common.get_layer("shot").add_child(shot)
	shot.position = position
	var v = Vector2()
	var rad = deg_to_rad(270 + randf_range(-45, 45))
	var spd = randf_range(100, 1000)
	v.x = cos(rad) * spd
	v.y = -sin(rad) * spd
	shot.set_velocity(v)

func _update_absorb(delta:float) -> void:
	if _absorb_timer <= 0.0:
		return
	_absorb_timer -= delta
	var rate = _absorb_timer / TIMER_BARRIER_HIT
	rate = elastic_in(rate)
	if rate > 0.9:
		rate = 0.9
	_barrier_spr.scale = _absorb_scale_base * (1.0 - rate * 0.1)
	
func _update_option(delta:float) -> void:
	if Common.is_guard:
		_option.visible = true
		for obj in _option.get_children():
			obj.disable_mode = CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE
			obj.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		_option.visible = false
		for obj in _option.get_children():
			obj.disable_mode = CollisionObject2D.DISABLE_MODE_REMOVE
			obj.process_mode = Node.PROCESS_MODE_DISABLED
		
	_option.rotation += delta * 8
	
func _update_anim(delta:float) -> void:
	if _move_timer > TIMER_MOVE:
		_move_timer = TIMER_MOVE
	_move_timer -= delta
	if _move_timer < 0.0:
		_move_timer = 0.0
	var rate = _move_timer / TIMER_MOVE
	var sc = _spr_base_sc.x - 0.5 * rate
	_spr.scale = Vector2(sc, _spr_base_sc.y)
	
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
		if Common.is_absorb:
			var absorb = ABSORB_OBJ.instantiate()
			absorb.position = area.position
			Common.get_layer("particle").add_child(absorb)
		elif Common.is_reflect:
			var shot = SHOT_OBJ.instantiate()
			Common.get_layer("main").add_child(shot)
			var deg = area.get_direction()
			var spd = area.get_speed()
			shot.setup(area.position, deg + 180, -spd*0.5, true)
		
		# 逆方向にパーティクルを発生させる.
		var pos = area.position
		var v = area._velocity * -1
		var spd = v.length()
		for i in range(4):
			var rad = atan2(-v.y, v.x)
			var deg = rad_to_deg(rad)
			deg += randf_range(-30, 30)
			var speed = spd * randf_range(0.1, 0.5)
			Common.add_particle(pos, 1.0, deg, speed)
			
		area.vanish()

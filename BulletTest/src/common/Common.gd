extends Node

const ParticleObj = preload("res://src/particle/Particle.tscn")
const TIMER_SCREEN_SHAKE = 1.0

# 画面のサイズ.
const SCREEN_W = 1024.0
const SCREEN_H = 600.0

# 画面の中央.
const CENTER_X = SCREEN_W / 2
const CENTER_Y = SCREEN_H / 2

var _layers = null
var _player:Player = null
var _prev_target_pos = Vector2.ZERO

func setup(layers, player) -> void:
	_layers = layers
	_player = player

func is_in_screen(pos:Vector2) -> bool:
	if pos.x < 0 or pos.y < 0:
		return false
	if pos.x > SCREEN_W or pos.y > SCREEN_H:
		return false
	return true

func get_layer(name:String) -> CanvasLayer:
	return _layers[name]

func get_player() -> Player:
	if is_instance_valid(_player) == false:
		return null
	return _player

func get_aim(pos:Vector2) -> float:
	var player = get_player()
	var target = _prev_target_pos
	if player != null:
		target = player.position
	
	var d = target - pos
	var aim = rad_to_deg(atan2(-d.y, d.x))
	
	# ターゲットの座標を保存しておく.
	_prev_target_pos = target
	
	return aim

## 角度差を求める.
func diff_angle(now:float, next:float) -> float:
	# 角度差を求める.
	var d = next - now
	# 0.0〜360.0にする.
	d -= floor(d / 360.0) * 360.0
	# -180.0〜180.0の範囲にする.
	if d > 180.0:
		d -= 360.0
	return d

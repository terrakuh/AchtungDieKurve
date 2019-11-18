extends Node2D

signal player_moved(old_position)

var thickness = gamestate.DEFAULT_THICKNESS setget set_thickness
var player_name
var _alive = true
var _direction
var _direction_order = 1
puppet var _p_slave_position = null
puppet var _p_slave_rotation = null

func _ready():
	name = "player"

func init(player_name):
	self.player_name = player_name

sync func s_reset(position, rotation):
	self.position = position
	set_rot(rotation)
	set_thickness(gamestate.DEFAULT_THICKNESS)
	_alive = true
	_direction_order = 1
	_p_slave_position = null
	_p_slave_rotation = null

func set_thickness(val):
	scale = Vector2(val / gamestate.DEFAULT_THICKNESS, val / gamestate.DEFAULT_THICKNESS)
	thickness = val

func _handle_input():
	if Input.is_action_pressed("move_right"):
		rotate(gamestate.ANGLE)
	elif Input.is_action_pressed("move_left"):
		rotate(-gamestate.ANGLE)

func rotate(angle):
	set_rot(rotation + angle * _direction_order)
	rset_unreliable("_p_slave_rotation", rotation)

func set_rot(rot):
	rotation = rot
	_direction = Vector2.RIGHT.rotated(rot)

sync func s_die():
	_alive = false

master func m_flip_direction():
	_direction_order = 1 if _direction_order == -1 else -1

func _process(delta):
	if not _alive:
		return
	
	if is_network_master():
		_handle_input()
		emit_signal("player_moved", position)
		position.x += _direction.x * gamestate.SPEED * delta
		position.y += _direction.y * gamestate.SPEED * delta
		
		rset_unreliable("_p_slave_position", position)
	else:
		if _p_slave_position != null:
			emit_signal("player_moved", position)
			position = _p_slave_position
			_p_slave_position = null
		if _p_slave_rotation != null:
			set_rot(_p_slave_rotation)

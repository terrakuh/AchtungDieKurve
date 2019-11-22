extends Area2D

var _shape_count = 0
var _all_lines = []
var _line
var _thickness = gamestate.DEFAULT_THICKNESS
var color = Color.white setget set_color, get_color

class Line:
	var width
	var points = PoolVector2Array()
	func add_point(point):
		points.append(point)
	func get_point_count():
		return points.size()
	func remove_point(idx):
		points.remove(idx)

func _ready():
	name = "history"
	s_start_segment()


func _draw():
	for line in _all_lines:
		if line.get_point_count() >= 2:
			draw_polyline(line.points, color, line.width, true)
var p
func init(player):
	p = player
	if is_network_master():
		connect("body_entered", self, "_on_body_entered")
		player.connect("player_moved", self, "t")

func _on_body_entered(body):
	players.rpc("m_kill_player", body.player_name)

var s = Vector2.ZERO
func t(pos):
#	if p and pos.distance_to(Vector2.ZERO) > 400:
#		p.thickness = 18
#		set_thickness(18)
#		p = null
	if s.distance_to(pos) < _thickness * 1.75:
		var i = _line.get_point_count()
		if i:
			_line.remove_point(i-1)
		s_add_point(pos, false)
		return
	s = pos
	rpc("s_add_point", pos)

func set_color(c):
	color = c

func get_color():
	return color

sync func _s_set_thickness(thickness):
	_line.width = thickness * 2
	_thickness = thickness

func set_thickness(thickness):
	if _line.get_point_count() >= 2:
		rpc("s_start_segment")
	rpc("_s_set_thickness", thickness)

sync func s_start_segment():
	_line = Line.new()
	_line.width = _thickness * 2
	_all_lines.append(_line)

func _add_collision_point(point):
	var c = CollisionShape2D.new()
	c.name = "collision%d" % _shape_count
	_shape_count += 1
	c.position = point
	c.shape = CircleShape2D.new()
	c.shape.radius = _thickness
	add_child(c)

sync func s_add_point(point, with_collision=true):
	_line.add_point(point)
	update()
	if with_collision:
		_add_collision_point(point)

func reset():
	for i in get_children():
		remove_child(i)
	_all_lines = []
	set_thickness(gamestate.DEFAULT_THICKNESS)
	s_start_segment()

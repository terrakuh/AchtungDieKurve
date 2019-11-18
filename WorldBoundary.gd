extends Node

signal body_touched(body, proposed_position)

func _ready():
	$Left.connect("body_entered", self, "_on_body_entered", ["left"])
	$Bottom.connect("body_entered", self, "_on_body_entered", ["bottom"])
	$Right.connect("body_entered", self, "_on_body_entered", ["right"])
	$Top.connect("body_entered", self, "_on_body_entered", ["top"])
	_update_size(null, gamestate.game_size)
	gamestate.connect("size_changed", self, "_update_size")

func _update_size(__, size):
	$Left.set_size(Vector2(0, 0), Vector2(0, size.y))
	$Bottom.set_size(Vector2(0, size.y), size)
	$Right.set_size(Vector2(size.x, 0), size)
	$Top.set_size(Vector2(0, 0), Vector2(size.x, 0))

func _on_body_entered(body, position):
	print(body, "left")
	var pos
	match position:
		"right":
			pos = Vector2(0, body.position.y)
		"bottom":
			pos = Vector2(body.position.x, 0)
		"top":
			pos = Vector2(body.position.x, gamestate.game_size.y - 5)
		"left":
			pos = Vector2(gamestate.game_size.x - 5, body.position.y)
	emit_signal("body_touched", body, pos)


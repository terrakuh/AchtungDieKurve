extends Area2D

func set_size(a, b):
	$Shape.shape.a = a
	$Shape.shape.b = b
	$ColorRect.rect_position = a
	$ColorRect.rect_size = b - a + Vector2(5, 5)

func _ready():
	print("hi")
	$Shape.shape = SegmentShape2D.new()
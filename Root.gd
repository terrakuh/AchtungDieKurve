extends Node2D

func _ready():
	$World/WorldBoundary.connect("body_touched", gamestate, "body_hit_wall")
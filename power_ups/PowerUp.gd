extends Area2D

enum TYPE {
	ENEMIES,
	FRIENDS,
	NEUTRAL
}
enum ACTION {
	REVERSE
}

var _type
var _action
var _consumed = false

func init(type, action):
	_type = type
	
	match type:
		TYPE.ENEMIES:
			$Background.texture = preload("res://power_ups/enemies.png")
		TYPE.FRIENDS:
			$Background.texture = preload("res://power_ups/friends.png")
		TYPE.NEUTRAL:
			$Background.texture = preload("res://power_ups/neutral.png")
	
	match action:
		ACTION.REVERSE:
			_action = "_reverse"
			$Icon.texture = preload("res://power_ups/reverse.png")
	
	if get_tree().is_network_server():
		connect("body_entered", self, "_on_body_entered")

sync func _s_remove():
	queue_free()

func _reverse(body):
	match _type:
		TYPE.ENEMIES:
			for i in players.get_alive_players():
				if body != i:
					i.rpc("m_flip_direction")
		TYPE.FRIENDS:
			body.rpc("m_flip_direction")
		TYPE.NEUTRAL:
			for i in players.get_alive_players():
				i.rpc("m_flip_direction")

func _on_body_entered(body):
	if not _consumed:
		_consumed = true
		call(_action, body)
		rpc("_s_remove")
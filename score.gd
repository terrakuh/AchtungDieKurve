extends Node

signal scores_changed(new_scores)

var _scores = {}

sync func s_set_score(name, score=0):
	_scores[name] = score
	_rearange()

sync func s_increment_score(name, by=1):
	_scores[name] += by
	_rearange()

func get_highscore():
	var highest = -1
	var name = ""
	for i in _scores:
		if _scores[i] > highest:
			name = i
			highest = _scores[i]
	return [name, highest]

class Sorter:
	static func sort(a, b):
		return a[1] < b[1]

func _rearange():
	var scores = []
	
	for i in _scores:
		scores.append([i, _scores[i]])
	
	scores.sort_custom(Sorter, "sort")
	emit_signal("scores_changed", scores)
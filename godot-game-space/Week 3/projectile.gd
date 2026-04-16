extends Area2D


var speed = 500
var direction = Vector2.ZERO

func set_direction(dir: Vector2):
	direction = dir

func _process(delta):
	position += direction * speed * delta

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(10)
		queue_free()

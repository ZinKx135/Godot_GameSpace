extends Area2D

@export var speed := 900
var direction := Vector2.RIGHT

func _process(delta):
	position += direction * speed * delta
	rotation = direction.angle()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(20)
	queue_free()

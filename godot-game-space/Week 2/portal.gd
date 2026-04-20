extends Area2D

@export var target_portal: NodePath

var teleport_locked := false
var last_body: Node = null

func _ready():
	$AnimatedSprite2D.play("Portal_idle")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):

	if teleport_locked:
		return

	if body is CharacterBody2D:
		var portal = get_node(target_portal)

		# teleport player
		body.global_position = portal.global_position + Vector2(0, 32)

		# lock portal tujuan
		portal.teleport_locked = true
		portal.last_body = body

func _on_body_exited(body):

	if body == last_body:
		teleport_locked = false
		last_body = null

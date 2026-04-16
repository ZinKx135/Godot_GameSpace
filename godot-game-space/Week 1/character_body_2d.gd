extends CharacterBody2D

@export var projectile_scene : PackedScene
@onready var ray_left = $RayCast2D_kiri
@onready var ray_right = $RayCast2D_kanan

var can_shoot = true

const SPEED = 300.0
const JUMP_VELOCITY = -800.0


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	
	check_raycast(ray_left)
	check_raycast(ray_right)

func check_raycast(ray):
	if ray.is_colliding():
		var target = ray.get_collider()
		
		if target == null:
			return
		
		if target.is_in_group("enemy"):
			shoot(target.global_position)

func shoot(target_pos):
	if not can_shoot:
		return
	
	can_shoot = false
	
	var bullet = projectile_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	
	var dir = (target_pos - global_position).normalized()
	bullet.set_direction(dir)
	
	await get_tree().create_timer(0.5).timeout
	can_shoot = true

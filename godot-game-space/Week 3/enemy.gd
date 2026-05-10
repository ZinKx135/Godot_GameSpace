extends CharacterBody2D

@export var laser_length := 5000.0
@export var damage := 20
@export var aim_time := 3.0
@export var cooldown := 2.0
@export var bullet_scene : PackedScene

@onready var ray_kanan = $RayCast2D_kanan
@onready var ray_kiri = $RayCast2D_kiri
@onready var hp_label = $Label
@onready var sfx_aim = $SFX_Aim
@onready var sfx_tembak = $SFX_Tembak

var laser_kanan : Line2D
var laser_kiri : Line2D

var player = null
var current_target := Vector2.ZERO

var hp = 100
var is_aiming = false
var can_shoot = true

func _ready():
	laser_kanan = create_laser()
	laser_kiri = create_laser()

	player = get_tree().get_first_node_in_group("Player")

	add_to_group("enemy")
	update_hp_label()

func _process(delta):
	if can_shoot and !is_aiming:
		check_target()

func check_target():

	# cek kanan dulu
	if ray_detect_player(ray_kanan, laser_kanan, Vector2.RIGHT):
		start_aim(ray_kanan, laser_kanan, Vector2.RIGHT)
		return

	# cek kiri
	if ray_detect_player(ray_kiri, laser_kiri, Vector2.LEFT):
		start_aim(ray_kiri, laser_kiri, Vector2.LEFT)
		return

func ray_detect_player(ray, laser, dir):

	ray.target_position = dir * laser_length
	ray.force_raycast_update()

	if ray.is_colliding():
		var obj = ray.get_collider()

		if obj.is_in_group("Player"):
			return true

	return false

func start_aim(ray, laser, dir):

	is_aiming = true
	can_shoot = false
	
	sfx_aim.pitch_scale = randf_range(0.95, 1.05)
	sfx_aim.play()
	# matikan sisi lain
	if dir == Vector2.RIGHT:
		laser_kiri.visible = false
	else:
		laser_kanan.visible = false

	laser.visible = true

	var timer := 0.0

	while timer < aim_time:

		update_laser_tracking(laser, ray)

		timer += get_process_delta_time()
		await get_tree().process_frame

	if ray.is_colliding():
		var obj = ray.get_collider()
		if obj.is_in_group("Player"):
			shoot((player.global_position - global_position).normalized())
	
	sfx_aim.stop()
	laser.visible = false
	
	await get_tree().create_timer(cooldown).timeout

	is_aiming = false
	can_shoot = true

func update_laser_tracking(laser, ray):

	if player == null:
		return

	var direction = (player.global_position - global_position).normalized()

	ray.target_position = direction * laser_length
	ray.force_raycast_update()
	
	var end_point : Vector2

	if ray.is_colliding():
		end_point = to_local(ray.get_collision_point())
	else:
		end_point = direction * laser_length
	
	current_target = current_target.lerp(end_point, 0.1)

	laser.clear_points()
	laser.add_point(Vector2.ZERO)
	laser.add_point(current_target)

func shoot(direction):
	sfx_tembak.pitch_scale = randf_range(0.95, 1.05)
	sfx_tembak.play()

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = global_position + direction * 100

	bullet.direction = direction

func create_laser() -> Line2D:
	var l = Line2D.new()
	l.width = 5
	l.default_color = Color.RED
	l.visible = false
	add_child(l)
	return l

func take_damage(dmg):
	hp -= dmg
	update_hp_label()

	if hp <= 0:
		die()

func update_hp_label():
	hp_label.text = str(hp)

func die():
	queue_free()

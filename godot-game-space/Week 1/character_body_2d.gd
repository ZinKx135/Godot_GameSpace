extends CharacterBody2D

@export var laser_length := 800.0
@export var damage := 10
@onready var ray_kanan = $RayCast2D_kanan
@onready var ray_kiri = $RayCast2D_kiri

var laser_kanan: Line2D
var laser_kiri: Line2D

const SPEED = 300.0
const JUMP_VELOCITY = -800.0

func _ready():
	laser_kanan = buat_laser()
	laser_kiri = buat_laser()

func buat_laser() -> Line2D:
	var l = Line2D.new()
	l.width = 10
	l.default_color = Color.BLUE_VIOLET
	l.visible = false
	add_child(l)
	return l

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
			
func _process(delta):
	check_raycast(ray_kanan, laser_kanan, Vector2.RIGHT)
	check_raycast(ray_kiri, laser_kiri, Vector2.LEFT)

func check_raycast(ray: RayCast2D, laser: Line2D, dir: Vector2):
	ray.target_position = dir * laser_length
	ray.force_raycast_update()

	# default mati
	laser.visible = false

	if ray.is_colliding():
		var obj = ray.get_collider()

		#aktif kalau kena group enemy
		if obj.is_in_group("enemy"):
			# tampilkan laser
			laser.visible = true
			laser.clear_points()
			laser.add_point(Vector2.ZERO)

			var hit = to_local(ray.get_collision_point())
			laser.add_point(hit)

			#damage
			if obj.has_method("take_damage"):
				obj.take_damage(damage)

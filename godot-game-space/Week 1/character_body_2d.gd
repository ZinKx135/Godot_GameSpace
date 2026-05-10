extends CharacterBody2D

@export var laser_length := 600.0
@export var damage := 4
@export var max_hp := 100

@onready var sfx_lompat = $SFX_Lompat
@onready var sfx_laser = $SFX_Laser
@onready var ray_kanan = $RayCast2D_kanan
@onready var ray_kiri = $RayCast2D_kiri
@onready var hp_label = $Label

var hp := 100
var hp_bar = null
var hp_text = null

var laser_kanan: Line2D
var laser_kiri: Line2D
var laser_aktif := false
var damage_interval := 0.1
var damage_timer := 0.0
var di_udara := false

const SPEED = 300.0
const JUMP_VELOCITY = -800.0


func _ready():
	hp = max_hp
	hp_bar = get_tree().get_first_node_in_group("hp_bar")
	hp_text = get_tree().get_first_node_in_group("hp_text")
	update_hp_label()
	laser_kanan = buat_laser()
	laser_kiri = buat_laser()

func buat_laser() -> Line2D:
	var l = Line2D.new()
	l.width = 10
	l.default_color = Color.BLUE_VIOLET
	l.begin_cap_mode = Line2D.LINE_CAP_ROUND
	l.end_cap_mode = Line2D.LINE_CAP_ROUND
	l.antialiased = true
	l.visible = false
	add_child(l)
	return l

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity += get_gravity() * delta
		di_udara = true

	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		sfx_lompat.pitch_scale = randf_range(0.9, 1.1)
		sfx_lompat.play()
		di_udara = false

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
			
func _process(delta):
	damage_timer += delta
	var kanan_aktif = check_raycast(
		ray_kanan,
		laser_kanan,
		Vector2.RIGHT
	)
	var kiri_aktif = check_raycast(
		ray_kiri,
		laser_kiri,
		Vector2.LEFT
	)
	var ada_laser = kanan_aktif or kiri_aktif
	if ada_laser:
		if !laser_aktif:
			sfx_laser.pitch_scale = randf_range(0.98, 1.02)
			sfx_laser.play()
			laser_aktif = true
	else:
		if laser_aktif:
			sfx_laser.stop()
			laser_aktif = false

func check_raycast(
	ray: RayCast2D,
	laser: Line2D,
	dir: Vector2
) -> bool:
	ray.target_position = dir * laser_length
	ray.force_raycast_update()
	laser.visible = false
	if ray.is_colliding():
		var obj = ray.get_collider()
		if obj.is_in_group("enemy"):
			laser.visible = true
			laser.clear_points()
			laser.add_point(Vector2.ZERO)
			var hit = laser.to_local(
				ray.get_collision_point()
			)
			laser.add_point(hit)
			if damage_timer >= damage_interval:
				damage_timer = 0.0
				if obj.has_method("take_damage"):
					obj.take_damage(damage)
			return true
	return false
	
func take_damage(dmg):
	hp -= dmg
	update_hp_label()

	if hp <= 0:
		die()

func update_hp_label():
	if hp_text:
		hp_text.text = str(hp)
	if hp_bar:
		if hp == 100:
			hp_bar.modulate = Color.GREEN
		create_tween().tween_property(
			hp_bar,
			"value",
			hp,
			0.2
		)
		if hp >= 70:
			hp_bar.modulate = Color.GREEN
		elif hp >= 30:
			hp_bar.modulate = Color.YELLOW
		else:
			hp_bar.modulate = Color.RED

func die():
	print("Player mati")
	queue_free()

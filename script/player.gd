extends CharacterBody3D

@onready var cam_mount = $CamMount
@onready var spring_arm = $CamMount/SpringArm3D
@onready var anim = $Mesh/mixamo_base/AnimationPlayer
@onready var mesh = $Mesh

var speed = 3.5
const JUMP_VELOCITY = 4.5
var sens = 0.2
var lerp_val = .1

var walk_speed = 3.5
var run_speed = 6.0

var running = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		cam_mount.rotate_y(deg_to_rad(-event.relative.x*sens))
		spring_arm.rotate_x(deg_to_rad(-event.relative.y*sens))
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)

func _physics_process(delta):
	if Input.is_action_pressed("run"):
		speed = run_speed
		running = true
	else:
		speed = walk_speed
		running = false
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, cam_mount.rotation.y)
	if direction:
		if running:
			if anim.current_animation != "running":
				anim.play("running")
		else:
			if anim.current_animation != "walking":
				anim.play("walking")
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-velocity.x, - velocity.z), lerp_val)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if anim.current_animation != "idle":
			anim.play("idle")
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

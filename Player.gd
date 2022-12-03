extends CharacterBody3D

@export var mouse_sense : float = 0.1
@onready var head = $head
@onready var camera = $head/Camera3D
@onready var flight_energy = $flight_energy

var speed = 7
var head_colliding = false
const JUMP_VELOCITY = 7.0

var crouched = false
var jumping = false
var flying = false
var cooldown = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 2*ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	if jumping:
		if Input.is_action_just_pressed("ui_accept"):
			flying = true
			
	if flying:
		if Input.is_action_pressed("ui_accept") and flight_energy.value > 0 and !cooldown:
			flight_energy.value -= 50*delta
			velocity.y = 2
		else:
			flying = false
			if (flight_energy.value == 0):
				cooldown = true
				await get_tree().create_timer(1).timeout
				cooldown = false
	else:
		flight_energy.value += 10*delta
		
		
	# Add the gravity.
	if not is_on_floor() and not flying:
		velocity.y -= gravity * delta
	elif not flying:
		jumping = false
		

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		velocity.y += gravity * delta
		jumping = true
	
		
	if Input.is_action_pressed("sprint"):
		speed = 14
		camera.fov = lerp(camera.fov, 110.0, 0.1)
	else:
		speed = 10
		camera.fov = lerp(camera.fov, 90.0, 0.1)
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	camera.rotation.z = lerp_angle(camera.rotation.z, -input_dir.x/16, 0.1)
	
	
	if direction:
		velocity.x = move_toward(get_real_velocity().x, direction.x * speed, 1)
		velocity.z = move_toward(get_real_velocity().z, direction.z * speed, 1)
	else:
		velocity.x = move_toward(get_real_velocity().x, 0, speed)
		velocity.z = move_toward(get_real_velocity().z, 0, speed)
		

	if Input.is_action_pressed("crouch") and $RayCast3D.is_colliding():
		crouched = true
		head.position.y = lerp(head.position.y, -0.2, 0.1)
	else:
		crouched = false
		head.position.y = lerp(head.position.y, 0.5, 0.1)

	move_and_slide()



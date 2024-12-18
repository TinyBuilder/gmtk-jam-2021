extends RigidBody2D

export (int) var acceleration = 100
export (int) var max_force = 1000
export (int) var max_speed = 100
export (int) var jump_speed = 1000
export (int) var max_distance = 100

var velocity = Vector2()
var boulder_v = Vector2()
var jumping = false
var jumped = false
var boulder = null
var tether = Vector2()
var up_direction = Vector2(0, -1)
var pulled = false
var pulling = false
var push_power = 0
var pushing = false
var impulse = Vector2()
var approaching = false
var floating = false
var start = Vector2()
var boulder_start = Vector2()

const Chain = preload("res://Chain.tscn")
var chains = []

func _ready():
	start = get_global_position()
	if get_parent().has_node("Boulder"):
		boulder = get_parent().get_child(1)
		boulder.set_friction(1)
		for i in range(20):
			chains.append(Chain.instance())
			print(chains[i-1])
			add_child(chains[i-1])
		
		boulder_start = boulder.get_global_position()

func kill():
	get_tree().reload_current_scene()

func get_input():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var reset = Input.is_action_pressed('ui_accept')
	
	impulse.x = 0
	impulse.y = 0
	
	if reset:
		kill()
	if right:
		impulse.x += acceleration
	if left:
		impulse.x -= acceleration
	if get_linear_velocity().x > max_speed:
		impulse.x = 0

func _process(_delta):
	pulling = false
	pulled = false
	pushing = false
	approaching = false
	get_input()
	tether = boulder.global_position - global_position
	var i = 1
	for chain in chains:
		chain.set_position(tether / 20 * i)
		i += 1

func _integrate_forces(state):
	set_friction(1)
	
	if tether.length() < 48:
		pushing = true
		boulder.apply_central_impulse(tether.normalized() * max_force)
		
	var collisions = get_colliding_bodies()
	if collisions:
		# get collision info
		var normal = state.get_contact_local_normal(0)
		if normal.y != 0:
			impulse = impulse.slide(normal)
	else:
		floating = true
	
	var next_pos = global_position + impulse
	if next_pos.distance_to(boulder.global_position) < global_position.distance_to(boulder.global_position):
		approaching = true
	
	if tether.length() > max_distance:
		pulling = true
		boulder_v = boulder.get_linear_velocity()
		if boulder_v.length() < max_speed or approaching:
			boulder.apply_central_impulse(tether.normalized() * -1 * max_force)
		else:
			pulled = true
			boulder.apply_central_impulse(tether.normalized() * -1 * max_force * (tether.length() - max_distance) / tether.length())
	
	if pulling and not approaching:
		impulse = impulse * (acceleration - (tether.length() - max_distance)) / acceleration
	
	if pulled:
		impulse = tether
		set_friction(0)
	elif get_linear_velocity().length() > max_speed:
		set_linear_velocity(get_linear_velocity().normalized() * max_speed)
	
	apply_central_impulse(impulse)
	
	if impulse.x > 0.1:
		$AnimatedSprite.set_flip_h(false)
	elif impulse.x < -0.1:
		$AnimatedSprite.set_flip_h(true)
	
	if pushing:
		$AnimatedSprite.play("pushing")
	elif pulling and not approaching:
		$AnimatedSprite.play("pulling")
	elif abs(get_linear_velocity().x) < 0.1:
		$AnimatedSprite.play("default")
	else:
		$AnimatedSprite.play("walk")
	

extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var hovered = false
onready var lastHovered = false
var id = 0
var size = Vector2()
var gridPos = Vector2()
var spacing = 55
var colors = {1:Color(255,0,0),2:Color(0,255,0),3:Color(0,0,255),4:Color(255,255,0),5:Color(255,0,255)}

signal tileClicked(tile)

# Called when the node enters the scene tree for the first time.
func _init():
	id = randi()%5+1

func _ready():
	self_modulate = colors[id]
	
func _physics_process(delta):
	if(lastHovered != hovered):
		if(hovered):
			material.set_shader_param("color",Color(255,255,255,255))
		else:
			material.set_shader_param("color",Color(255,255,255,0))
		lastHovered = hovered
#	if(gridPos != position):
#		position = Vector2(gridPos.x*50*1.1,gridPos.y*50*1.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if !hovered:
		return
	if event.is_action_pressed("ui_accept"):
		print(id)
		emit_signal("tileClicked",self)

func _on_Area2D_mouse_entered():
	hovered = true


func _on_Area2D_mouse_exited():
	hovered = false
	
func set_size(new_size: Vector2):
  size = new_size
  scale = size / texture.get_size()

func drop_and_slide():
	if(gridPos != position):
		var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tween.tween_property(self,"position",Vector2(position.x,gridPos.y*spacing),.3)
		if(gridPos.x*spacing != position.x):
			tween.tween_property(self,"position",Vector2(gridPos.x*spacing,gridPos.y*spacing),.3)
			

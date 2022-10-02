extends Node2D

var count = 0
var matchState = 0
var states = {0:"SHAPE",1:"COLOR",2:"FACE"}
var score = 0
var totalScore = 0
var level = 1
const progBarMax = 281
const pauseScreen = preload("res://pauseScreen.tscn")
onready var indicators = [$IndicatorBg/IndicatorS,$IndicatorBg/IndicatorC,$IndicatorBg/IndicatorE]
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Start/Button.connect("pressed",self,"startGame")
	$Board.connect("pastLimit",self,"gameOver")
	$Board.connect("sfxCue",self,"playSFX")
	$Board.connect("score",self,"scoreUp")
	$pauseScreen/pauseButton.connect("pressed",self,"unpause")
	$pauseScreen/ColorRect/SFXOff.connect("toggled",self,"toggleSfx")
	$pauseScreen/ColorRect/BGMOff.connect("toggled",self,"toggleBgm")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer2_timeout():
	count+=1
	if(count == 10):
		tenTicks()
	$TimerIndicator.rotation_degrees = 36*count 
	
func tenTicks():
	$Board._addNewCol()
	indicators[matchState].set_visible(false)
	matchState = matchState + 1
	matchState = matchState%3
	indicators[matchState].set_visible(true)
	$matchLabel.set_text(states[matchState])
	$Board._updateIDs(matchState)
	count = 0
	
func gameOver():
	$gameOver.set_visible(true)
	$gameOver/GameOverText.text = "GAME OVER\n\nWAVES SURVIVED:"+str(level-1)+"\n\nTOTAL SCORE:"+str(totalScore)
	$gameOver/Button.connect("pressed",self,"restart")
	$Timer2.stop()
	
func playSFX(sfx):
	if($SFXPlayer.is_playing()):
		$SFXPlayer2.stream = load(sfx)
		$SFXPlayer2.play()
	else:
		$SFXPlayer.stream = load(sfx)
		$SFXPlayer.play()
		
func scoreUp(s):
	score += s
	totalScore += s
	var levelMax = level*1000
	if(score>= levelMax):
		score = int(score)%levelMax
		level+=1
		$Board.nukeBoard()
		for i in range(9):
			$Board._addNewCol()
	var size = (score/levelMax)*progBarMax
	$ProgressBar/progressBarRect.rect_size.x = size
	$ProgressBar/progressBarLabel.text = str(score) + "/"+str(levelMax)
		
func pause():
	$pauseScreen.set_visible(true)
	$Timer2.set_paused(true)
	
	
func unpause():
	$Timer2.set_paused(false)
	$pauseScreen.set_visible(false)
	
func toggleSfx(pressed):
	if(pressed):
		$SFXPlayer2.volume_db = -1000
		$SFXPlayer.volume_db = -1000
	else:
		$SFXPlayer2.volume_db = 0
		$SFXPlayer.volume_db = 0
	
func toggleBgm(pressed):
	if(pressed):
		$bgmPlayer.stop()
	else:
		$bgmPlayer.play()
		
func restart():
	get_tree().reload_current_scene()
	
func startGame():
	$Start.set_visible(false)
	$Timer2.start()

extends Node

## Emitted when the transition manager can be used, probably only useful for children of the [TransitionManager], because their readys are called before this.
signal transitions_registered

signal transition_fully_visible
signal transition_fully_hidden

const TRANSITION_COME_ANIM: StringName = &"TransitionCome"
const TRANSITION_GO_ANIM: StringName = &"TransitionGo"

@export var transitions: Array[TransitionEntry]
@export var transition_parent: Node

var _name_to_transition_ap: Dictionary[StringName, AnimationPlayer]

var _target_transition: StringName = ""
var _transition_anim_finished := true


func _ready() -> void:
	for transition_entry in transitions:
		assert(
			not _name_to_transition_ap.has(transition_entry.name),
			'Duplicate transtion name: "%s"' % transition_entry.name,
		)

		var transition_node := GodotUtils.instantiate(
			transition_entry.scene,
			Vector2.ZERO,
			0,
			false,
			transition_parent,
		)

		assert(
			transition_node.has_node("AnimationPlayer")
			and (transition_node.get_node("AnimationPlayer") as AnimationPlayer),
			'Transition: "%s" must have an animation player as a child named "AnimationPlayer"'
			% transition_entry.name,
		)
		var transition_ap := transition_node.get_node("AnimationPlayer") as AnimationPlayer

		_name_to_transition_ap[transition_entry.name] = transition_ap

		transition_ap.animation_finished.connect(_on_transition_animation_finished)

	transitions_registered.emit()


## Show the transition if a coming transition is not already playing or fully finished.
## Use [signal transition_fully_visible] to react to it finishing.
## The signal might instantly trigger if the transition if already fully visible.
##
## [param transition] is the the name of the transition to play as defined in [member transitions].
## [param force] causes the transition to even play if one is already playing or has finished playing.
## This means that the transition will just instantly cut to the first frame of this animation.
func transition_come(transition: StringName, force: bool = false) -> void:
	assert(
		_name_to_transition_ap.has(transition),
		'No transition exists with the name: "%s"' % transition,
	)

	if not force and _target_transition != "":
		if _transition_anim_finished:
			_on_transition_animation_finished(TRANSITION_COME_ANIM)

		return

	if _target_transition != "":
		_insta_hide_transition(_target_transition)
	# Emit fully hidden signal if skipping to the end of the anim, because it didn't finish yet (scripts might rely on a transition they case sending the signal)
	elif _transition_anim_finished == false:
		transition_fully_hidden.emit()

	_target_transition = transition
	_transition_anim_finished = false

	_name_to_transition_ap[transition].play(TRANSITION_COME_ANIM)


## Hide the transition if a going transition is not already playing or fully finished.
## Use [signal transition_fully_hidden] to react to it finishing.
## The signal might instantly trigger if the transition if already fully hidden.
##
## [param transition] is the the name of the transition to play as defined in [member transitions].
## [param force] causes the transition to even play if one is already playing or has finished playing.
## This means that the transition will just instantly cut to the first frame of this animation.
func transition_go(transition: StringName, force: bool = false) -> void:
	assert(
		_name_to_transition_ap.has(transition),
		'No transition exists with the name: "%s"' % transition,
	)

	if not force and _target_transition == "":
		if _transition_anim_finished:
			_on_transition_animation_finished(TRANSITION_GO_ANIM)

		return

	if _target_transition != "":
		# If the currently visible transition is not the transition that we are going to use now to go away,
		# hide it instantly so there's no overlapping transitions
		if transition != _target_transition:
			_insta_hide_transition(_target_transition)

		# Emit fully visible signal if skipping to the end of the anim, because it didn't finish yet (scripts might rely on a transition they case sending the signal)
		if _transition_anim_finished == false:
			transition_fully_visible.emit()

	_target_transition = ""
	_transition_anim_finished = false

	_name_to_transition_ap[transition].play(TRANSITION_GO_ANIM)


func _insta_hide_transition(transition: StringName) -> void:
	_name_to_transition_ap[transition].play(TRANSITION_GO_ANIM)
	_name_to_transition_ap[transition].advance(999999999)


func _on_transition_animation_finished(anim_name: StringName) -> void:
	## For some reason the animation finished signal is emitted a frame before it actually does, so wait one frame so the screen actually gets fully covered by the transition
	await get_tree().process_frame

	_transition_anim_finished = true

	if anim_name == TRANSITION_COME_ANIM:
		transition_fully_visible.emit()
	elif anim_name == TRANSITION_GO_ANIM:
		transition_fully_hidden.emit()
	else:
		assert(false, 'Invalid transition anim name: "%s"' % anim_name)

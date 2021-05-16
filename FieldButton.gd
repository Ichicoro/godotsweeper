extends Control
class_name Fieldbox

signal discover(position)   # position: Vector2
signal mark

enum Status {
    HIDDEN,
    MARKED,
    DISCOVERED
}

var blockState: int = Status.HIDDEN
var hasBomb: bool = false
var amountOfCloseBombs: int = 0

var holdStartTime: int = 0

func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and self.get_rect().has_point(event.position):
        print((event as InputEventScreenTouch).position)
        self.handle_touch(event)

func handle_touch(event: InputEventScreenTouch) -> void:
    # If the tile has already been discovered, do nothing
    if self.blockState == Status.DISCOVERED:
        return

    if event.pressed:
        self.holdStartTime = OS.get_ticks_msec()
        self.modulate = Color.darkgray
        yield(get_tree().create_timer(0.250), "timeout")
        handle_auto_hold()
    else:
        if self.holdStartTime == 0:
            return
        var elapsed = OS.get_ticks_msec() - self.holdStartTime
        self.holdStartTime = 0
        print("elapsed: ", elapsed)
        if elapsed > 250:
            if self.blockState == Status.HIDDEN:
                mark()
            else:
                reset()
        else:
            discover()

func handle_auto_hold():
    if self.holdStartTime != 0:
        if self.blockState == Status.HIDDEN:
            mark()
        else:
            reset()
        self.holdStartTime = 0

func discover():
    print("discovering tile")
    self.modulate = Color.red
    self.blockState = Status.DISCOVERED

func mark():
    print("marked tile")
    self.blockState = Status.MARKED
    self.modulate = Color.cadetblue

func reset():
    self.blockState = Status.HIDDEN
    self.modulate = Color.white

func get_texture() -> Texture:
    return null

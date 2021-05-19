tool
extends MarginContainer

export var MAX_SPAN: int

func _init():
    connect("resized", self, "_on_SpanLimiter_resized")

func _on_SpanLimiter_resized():
    if MAX_SPAN:
        _limit_span()

func _limit_span():
    if self.rect_size.x > MAX_SPAN:
        var half_margin = (self.rect_size.x - MAX_SPAN) / 2
        
        self.set("custom_constants/margin_left", 5)
        self.set("custom_constants/margin_right", self.rect_size.x - MAX_SPAN)
    
    else:
        self.set("custom_constants/margin_left", 5)
        self.set("custom_constants/margin_right", 5)

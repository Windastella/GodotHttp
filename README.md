# GodotHttp

A HTTP Request class with Async using Thread suitable for REST API implementation.

## Example

**GET**

```
extends Node

onready var req = GodotHttp.new()

func _on_loading(s, l):
	print('size=',s,':length=',l)

func _on_loaded(r):
	print(r)
	
func _on_Button_pressed():
	var res = req.post('http://localhost','/index.php?id=1',8181,false,["Content-Type:application/json"])
	res.connect("loading",self,"_on_loading")
	res.connect("loaded",self,"_on_loaded")
```

**POST**
```
extends Node

onready var req = GodotHttp.new()

func _on_loading(s, l):
	print('size=',s,':length=',l)

func _on_loaded(r):
	print(r)
	
func _on_Button_pressed():
	var res = req.post('http://localhost','/',8181,false,'{"action":"getposts"}',["Content-Type:application/json"])
	res.connect("loading",self,"_on_loading")
	res.connect("loaded",self,"_on_loaded")
```
# GodotHttp Class
# Author: Nik Mirza
# Email: nik96mirza[at]gmail.com
class_name GodotHttp

var reqlist = []

class Request:
	var t
	var params
	var parent
	
	signal loading(s,l)
	signal loaded(r)
	
	func _init(p, param):
		params = param
		parent = p
		t = Thread.new()
		
		t.start(self,"_load",params)
		
	func _load(params):
		var err = 0
		var http = HTTPClient.new()
		err = http.connect(params.domain,params.port,params.ssl)
		if err:
			print('Connection Err:',err)
			return
			
		while(http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING):
			http.poll()
			OS.delay_msec(100)
			
		var headers = PoolStringArray(["User-Agent: Pirulo/1.0 (Godot)", "Accept:*/*"])
		headers.append_array(PoolStringArray(params.header))
		headers = Array(headers)
		
		if params.method == "get":
			err = http.request(HTTPClient.METHOD_GET,params.url,headers)
		elif params.method =="post":
			err = http.request(HTTPClient.METHOD_POST,params.url,headers,params.data)
			
		if err:
			print('Request Error:',err)
			return
			
		while (http.get_status() == HTTPClient.STATUS_REQUESTING):
			http.poll()
			OS.delay_msec(500)
			
		if http.get_status() == http.STATUS_CONNECTION_ERROR:
			print('Request Error:', http.STATUS_CONNECTION_ERROR )
			return
			
		var rb = PoolByteArray()
		if(http.has_response()):
			headers = http.get_response_headers_as_dictionary()
			while(http.get_status()==HTTPClient.STATUS_BODY):
				http.poll()
				var chunk = http.read_response_body_chunk()
				if(chunk.size()==0):
					OS.delay_usec(100)
				else:
					rb = rb+chunk
					call_deferred("_send_loading_signal",rb.size(),http.get_response_body_length())
					
		call_deferred("_send_loaded_signal")
		http.close()
		return rb.get_string_from_utf8()
	
	func _send_loading_signal(size,length):
		emit_signal("loading",size,length)
	 
	func _send_loaded_signal():
		var result = t.wait_to_finish()
		emit_signal("loaded",result)
		parent.erase_req(self)
	
func GET(domain,url,port,ssl, header=[]):
	var req = Request.new(self,{method="get",domain=domain,url=url,port=port,ssl=ssl,header=header})
	reqlist.push_front(req)
	return req
	
func POST(domain,url,port,ssl,data, header=[]):
	var req = Request.new(self,{method="post",domain=domain,url=url,port=port,ssl=ssl,data=data,header=header})
	reqlist.push_front(req)
	return req
	
func check_req(req):
	if reqlist.find(req) != -1:
		return true
	return false
	
func erase_req(req):
	reqlist.erase(req)
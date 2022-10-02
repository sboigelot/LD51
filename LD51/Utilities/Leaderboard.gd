extends Node

func get_base_uri():
	return "https://ldtobugisapiapi.azure-api.net/"

func _ready():
	post_entry("togis",100,30)
	get_top_time()
		
func get_top_score():
	$GetTopScoreHTTPRequest.request(get_base_uri() + "GetTimeBoard")

func get_top_time():
	$GetTopScoreHTTPRequest.request(get_base_uri() + "GetScoreBoard")

func post_entry(name:String, score:float, time:float):
	# Convert data to json string:
	var data_to_send = {"name": name,"score": score,"time": time}
	var query = JSON.print(data_to_send)
	var use_ssl = false
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	$PostEntryHTTPRequest.request(
		get_base_uri() + "AddHighscore",
		headers, 
		use_ssl, 
		HTTPClient.METHOD_POST, 
		query
	)

func _on_GetTopScoreHTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)

func _on_GetTopTimeHTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)

func _on_PostEntryHTTPRequest_request_completed(result, response_code, headers, body):
	pass # Replace with function body.

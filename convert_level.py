import json, sys

with open(sys.argv[1]) as f:
    tiled_level = json.load(f)

message = ""
for property in tiled_level["properties"]:
    if property["name"] == "elevator":
        hasElevator = property["value"]
    elif property["name"] == "message":
        message = property["value"]

custom_level = {
    "map": tiled_level['layers'][0]['data'],
    "links": [],
    "hasElevator": hasElevator,
    "message": message
}

print(json.dumps(custom_level, indent=4))

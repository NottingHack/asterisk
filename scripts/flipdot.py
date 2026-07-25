from mqtt import MQTT
import datetime

client = MQTT().connect()

time = datetime.datetime.now().astimezone().time().isoformat()

client.publish("nh/flipdot/comfy/text", str(time))

from mqtt import MQTT
import datetime

client = MQTT().connect()

time = datetime.datetime.now()

client.publish("nh/flipdot/comfy/text", str(time))

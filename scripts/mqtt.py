import paho.mqtt.client as mqtt

class MQTT:
    """Connect to Nottinghack's MQTT broker and send messages"""

    host = "10.0.0.4"
    port = 1883

    mqttc = None

    def connect(self):
        self.mqttc = mqtt.Client()
        self.mqttc.connect(self.host, self.port)
        return self.mqttc

    def send(self, msg):
        self.mqttc.publish(msg)


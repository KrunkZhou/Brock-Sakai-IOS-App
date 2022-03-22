import requests
import time
import random

s = requests.Session()

slpMaxTime=120
slpMinTime=60

while True:
    r = s.get('https://localhost/sakaiNoti/update.php',
              cookies={'SAKAIID': ''},
              verify=False)
    print(r.text)
    slptime=int((slpMaxTime-slpMinTime)*random.random()+slpMinTime) #睡眠长度 20-120sec 公式：(max-min)*random+min
    print("Countdown: "+str(slptime)+" sec")
    time.sleep(slptime)

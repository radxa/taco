#!/usr/bin/python3
import time
import subprocess
import RPi.GPIO as GPIO

output = lambda x: subprocess.check_output(x, shell=True).decode().strip()

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(13, GPIO.OUT, initial=GPIO.LOW)

p = GPIO.PWM(13, 120)
p.start(0)

lvs = (
  (55, 100),
  (50, 75),
  (45, 50),
  (40, 25),
  (35, 0)
)


def get_temp():
    return int(output('cat /sys/class/thermal/thermal_zone0/temp')) / 1000


def change_dc():
    temp = get_temp()
    for k, dc in lvs:
        if temp > k:
            p.ChangeDutyCycle(dc)
            print(f'{temp:0.2f} {dc}%')
            return


def main():
    while True:
        change_dc()
        time.sleep(60)


if __name__ == '__main__':
    main()

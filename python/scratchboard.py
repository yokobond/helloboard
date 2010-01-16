import serial

import struct
import time
from threading import Thread, Event

class ScratchBoard(Thread):
    """
    http://docs.python.org/library/doctest.html
    >>> s = ScratchBoard(4)
    COM4
    >>> s.start()
    >>> s.sensorValues
    [1023, 1023, 1023, 1023, 1023, 210, 1, 27]
    >>> s.stop()
    >>> s.sensorValues
    [0, 0, 0, 0, 0, 0, 0, 0]
    >>> s.restart()
    Helloboard started to read sensors...
    >>> s.stop()
    >>> s.sensorValues
    [0, 0, 0, 0, 0, 0, 0, 0]
    >>> s.restart()
    Helloboard started to read sensors...
    >>> s.sensorValues
    [1023, 1022, 1023, 1023, 1023, 228, 1, 28]
    >>> s.readButton()
    False
    >>> s.readLight()
    28
    >>> s.readResistanceA()
    1023
    >>> s.readResistanceB()
    1023
    >>> s.readResistanceC()
    1023
    >>> s.readResistanceD()
    1023
    >>> s.readSlide()
    27
    >>> s.readSound()
    4
    """

    def __init__(self, port):
        Thread.__init__(self)
        self._stop = Event()
#        self._stop = False
        self.port = port
        self.sensorValues= [0, 0, 0, 0, 0, 0, 0, 0]
        self.firmwareId = 0
        self.ser = serial.Serial(port-1, 38400)        
        print self.ser.portstr                
 

    def stop(self):
#        self.ser.close()
        self._stop.set()
        self.sensorValues= [0, 0, 0, 0, 0, 0, 0, 0]        
        
    def restart(self):
        if (not self.ser.isOpen):
            self.ser = serial.Serial(self.port-1, 38400)
        print "Helloboard started to read sensors..."
#        time.sleep(0.5)
        self._stop.clear()        

    def stopped(self):
        return self._stop.isSet()
        
    def getChannelWithValue(self, highByte, lowByte):
        channel = (highByte & 120 ) >> 3
        value = ((highByte & 7) << 7)+(lowByte & 127)
        return channel, value

    def setSensorValues(self, inBytes):
        for i in range(1,19,2):
            channel, value =self.getChannelWithValue(inBytes[i-1], inBytes[i])
#            print channel, value            
            if channel == 15:
                self.firmwareId = value
            else:
                self.sensorValues[channel] = value


    def readResistanceD(self):
        return self.sensorValues[0]

    def readResistanceC(self):
        return self.sensorValues[1]
    
    def readResistanceB(self):
        return self.sensorValues[2]

    def readButton(self):
        return (self.sensorValues[3] < 10)

    def readResistanceA(self):
        return self.sensorValues[4]

    def readLight(self):
        return self.sensorValues[5]

    def readSound(self):
        return self.sensorValues[6]

    def readSlide(self):
        return self.sensorValues[7]


    def run(self):
        while True:
            if (not self._stop.isSet()):                
                self.ser.write(struct.pack('1B',1))
                time.sleep(0.02)
                inBytes = struct.unpack('18B',self.ser.read(18))
                self.setSensorValues(inBytes)
            else:
#                print "\nHelloboard stopped."
                if self.ser.isOpen():
                    self.sensorValues= [0, 0, 0, 0, 0, 0, 0, 0]        
#                    self.ser.close()

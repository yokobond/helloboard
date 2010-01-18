import serial
import struct
import time
from threading import Thread, Event, Lock

class ScratchBoard(Thread):
    """
    >>> s = ScratchBoard(18)
    COM18
    >>> s.start()
    >>> s.suspend()
    >>> s.resume()
    Helloboard was started to read sensors...
    >>> time.sleep(5)
    >>> s.sensorValues
    [1023, 1023, 1023, 1023, 1023, 210, 1, 27]
    >>> s.suspend()
    >>> s.sensorValues
    [0, 0, 0, 0, 0, 0, 0, 0]
    >>> s.resume()
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
    >>> s.terminate()
    """

    def __init__(self, port):
        Thread.__init__(self)
        self._stop = Event()
        self._suspend_lock = Lock()
        self._terminate = False
        self.port = port
        self.sensorValues= [0, 0, 0, 0, 0, 0, 0, 0]
        self.firmwareId = 0
        self.ser = serial.Serial(port-1, 38400)
        print self.ser.portstr

    def start(self,port):
        Thread.start(self)

    def terminate(self):
#        self.suspend()
        self._terminate = True
        time.sleep(0.3)
#        self._stop.set()
        self.sensorValues= [0, 0, 0, 0, 0, 0, 0, 0]
        if self.ser.isOpen():
            self.ser.close()

    def suspend(self):
        self._suspend_lock.acquire()

    def resume(self):
        self._terminate = False
        self._suspend_lock.release()
        if (not self.ser.isOpen()):
            self.ser = serial.Serial(self.port-1, 38400)
            print "reassign serial port"
        print "Helloboard was started to read sensors..."
#        time.sleep(0.5)

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
            if self._terminate:
                self.sensorValues= [0, 0, 0, 0, 0, 0, 0, 0]
                break
            self._suspend_lock.acquire()
            self._suspend_lock.release()
            self.ser.write(struct.pack('1B',1))
            time.sleep(0.02)
            inBytes = struct.unpack('18B',self.ser.read(18))
            self.setSensorValues(inBytes)

# if __name__ == '__main__':
#     import doctest
#     doctest.testmod()

/*
  you can put a one sentence description of your library here.
  
  (c) copyright
  
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General
  Public License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
 */

package cc.piny;

import processing.core.PApplet;
import processing.serial.Serial;

/**
 * this is a template class and can be used to start a new processing library.
 * make sure you rename this class as well as the name of the package template
 * this class belongs to.
 * 
 * @example ScratchBoard 
 * @author Donghee Park
 * 
 */
public class ScratchBoard implements Runnable {
	PApplet parent;
	Serial serial;
	SerialProxy serialProxy;

	int[] sensorValues= {0, 0, 0, 0, 0, 0, 0, 0};	
	int highByteValue;
	int lowByteValue;
	int channel;
	boolean isLowByte = false;
	
	int firmwareId;
	public final String VERSION = "0.1.0";
	private Thread thread;

	public class SerialProxy extends PApplet {
		public SerialProxy() {
			disposeMethods = new RegisteredMethods();
		}
		
		public void serialEvent(Serial which) {
			while (available() > 0 )
				processInput();
		}
	}
	
	public static String[] list() {
		return Serial.list();
	}

	public ScratchBoard(PApplet parent, String iname) {
		this(parent, iname, 38400);

	}
	/**
	 * a Constructor, usually called in the setup() method in your sketch to
	 * initialize and start the library.
	 * 
	 * @example ScratchBoard
	 * @param theParent
	 */
	public ScratchBoard(PApplet parent, String iname, int irate) {
		this.parent = parent;
		this.serialProxy = new SerialProxy();
		this.serial = new Serial(serialProxy, iname, irate);

		try {
			Thread.sleep(3000);
		} catch (InterruptedException e) {}
		
		//serial.write(0x01);
		start();
		
		parent.registerDispose(this);
	}
	
	private void start() {
		thread = new Thread(this);
		thread.start();
	}
	
	@Override
	public void run() {
		// TODO Auto-generated method stub
		while(true) {
			try {
				Thread.sleep(20);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			serial.write(0x01);
			
		}
		
	}
	
	private void stop() {
		thread = null;
	}
	
	
	public void dispose() {
		stop();
		this.serial.dispose();
		
	}
	
	public void processInput() {
		// TODO Auto-generated method stub
		int inByte;
		int val;

		inByte = serial.read();
		val = inByte;

		if (128 <= val) {
			// HighByte;
			channel = (val & 120) >> 3; // GETCHALLEL;
			highByteValue = val & 7;
		} else {
			// LowByte;
			lowByteValue = val & 127;
			val = (highByteValue << 7) + lowByteValue;

			if (channel == 15) {
				firmwareId = val;
				return;
			}

			setSensorValue(channel, val);
		}

	}

	private void setSensorValue(int channel, int sensorValue) {
		// TODO Auto-generated method stub
		sensorValues[channel] = sensorValue;
		
	}

	public int available() {
		// TODO Auto-generated method stub
		return serial.available();		
	}

	/**
	 * return the version of the library.
	 * 
	 * @return String
	 */
	public String version() {
		return VERSION;
	}

 
	
	public int readSensorValue(int channel){
		
		/*
		
		serial.write(0x01);
		
		//TODO 30  인지 확신이 안감.
		try {
			Thread.sleep(30);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		*/
		
		return sensorValues[channel];
	}


	public int readResistanceD() {
		return readSensorValue(0);
	}
	
	public int readResistanceC() {
		return readSensorValue(1);
	}

	public int readResistanceB() {
		return readSensorValue(2);
	}

	public boolean readButton() {
		return (readSensorValue(3) < 10);
	}

	public int readResistanceA() {
		return readSensorValue(4);
	}

	public int readLight() {
		return readSensorValue(5);
	}

	public int readSound() {
		return readSensorValue(6);
	}

	public int readSlide() {
		return readSensorValue(7);
	}

	
}

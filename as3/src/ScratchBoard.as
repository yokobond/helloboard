/*
  This library based on as3-glue project.

  (c) copyright
  
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General
  Public License along with this library; if not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA 02111-1307 USA
*/

package
{
import flash.events.ProgressEvent;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.system.Security;

public class ScratchBoard extends Socket
{
  /*
  public static const HIGH:int=1;
  public static const INPUT:int=0;
  public static const LOW:int=0;
  public static const OFF:int=0;
  public static const ON:int=1;
  */

  public function ScratchBoard(host:String="127.0.0.1", port:int=5331)
  {
	super();

	if ((port < 1024) || (port > 65535))
	  {
		trace("ScratchBoard: Port must be from 1024 to 65535!");
	  }
	else
	  {
		_host=host;
		_port=port;
		//http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager04.html

		super.connect(_host, _port);
		// listen for socket data
		addListeners();
		writeByte(0x01); //1 is ok.
		//		trace("send 1 byte");
		flush();
	  }
  }

  protected var destroyed:Boolean;

  private var firmwareId:int;

  private var _host:String="127.0.0.1";
  private var _port:uint=5331;

  private var _channel:uint=0;
  private var _highByteValue:uint=0;
  private var _lowByteValue:uint=0;
  private var _sensorValues:Array =[0,0,0,0,0,0,0,0,0,0 ,0,0,0,0,0];

  public function destory():void
  {
	destroyed=true;
	removeListeners();
  }

  public function readSlide():int
  {
	return _sensorValues[7];
  }
  public function readResistanceD():int {
	return _sensorValues[0];
  }

  public function readResistanceC():int {
	return _sensorValues[1];
  }

  public function readResistanceB():int {
	return _sensorValues[2];
  }

  public function readButton():Boolean {
	return (_sensorValues[3] < 10);
  }

  public function readResistanceA():int {
	return _sensorValues[4];
  }

  public function readLight():int {
	return _sensorValues[5];
  }

  public function readSound():int {
	return _sensorValues[6];
  }

  private function addListeners():void
  {
	addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler, false, 0, true);
  }

  private function setSensorValue(channel:int, value:int):void {
	_sensorValues[channel] = value;
  }

  private function processData(val:int):void
  {
	// http://github.com/dh/helloboard/tree/master/processing/ScratchBoard/src/cc/piny/
	if ( val < 0) {
	  val = val + 256;
	  _channel = (val & 120) >> 3;
	  _highByteValue = val & 7;
	} else {
	  _lowByteValue = val & 127;
	  val = (_highByteValue << 7) + _lowByteValue;
	  if (_channel == 15) {
		firmwareId = val;
		return;
	  }
	  setSensorValue(_channel, val);
	}
  }

  private function removeListeners():void
  {
	removeEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler, false);
  }

  //---------------------------------------
  //	PRIVATE FUNCTIONS
  //---------------------------------------
  private function socketDataHandler(event:ProgressEvent):void
  {
	while (bytesAvailable > 1) {
	  processData(readByte()); //read firstByte 0
	  writeByte(0x01);
	  flush();
	}
  }
}
}
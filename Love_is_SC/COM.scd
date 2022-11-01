(
~sensor = ~sensor?();

~sensor.init={
	arg self, port="/dev/ttyUSB0", baudrate=115200, onFailure;
	self.isMonitoring = false;
	CmdPeriod.add(self);

	// self.portOpen = false;
	// while { self.portOpen.not } {
	try {
		self.openCOM(port,baudrate);
	} {
		"[SERIAL] can't open port %".format(port);
		if (onFailure.isFunction) { onFailure.() };
	}
	//}
};

~sensor.openCOM={
	arg self, port, baudrate=115200;
	self.closeCOM;
	self.serial = SerialPort(port,baudrate);
	self.startMonitor;
};

~sensor.closeCOM={
	arg self;
	if(self.serial.notNil){
		self.stopMonitor;
		self.serial.close;
		self.serPial=nil;
	}
};

~sensor.startMonitor={
	arg self;
	self.stopMonitor;
	self.isMonitoring = true;
	Tdef(\serialMonitor, {
		loop{
			var msg = self.serial.read;
			if (msg.asInteger == 127) { // read separator (char code 127)
				msg = self.serial.read;
				// if prev byte was separator, next must be trigger id
				self.onCharReceived(msg.asAscii);
			}
		}
	}).play;
};

~sensor.stopMonitor={
	arg self;
	self.isMonitoring = false;
	Tdef(\serialMonitor).stop.clear;
};

~sensor.onCharReceived = {
	arg self, char;
	var charCode = char.asInteger;
	if (charCode > 48 && charCode < 58) {
		var senderID = char.asString.asInteger;
		"[sensors] received trig from id %".format(senderID).postln;
		if((senderID > 0) && (senderID < 5)){
			Pdef(~pdefs[senderID-1]).play;
			senderID.postln;
		}
	}

};


~sensor.cmdPeriod = {
	arg self;
	if(self.isMonitoring) { self.startMonitor }
};
);

//~sensor.closeCOM
//~sensor.openCOM

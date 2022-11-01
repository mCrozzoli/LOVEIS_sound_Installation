(
h= h?();
h.init={
	arg self;
	self.buses=IdentityDictionary();
	self.heartrates=IdentityDictionary();
	self.initOSC;
};


h.initOSC={
	arg self;
	OSCdef(\miband, {
		arg msg;
		var id, heartRate;
		heartRate = msg[2];
		id = msg[1];
		postln("[heartbeat] %: %".format(id, heartRate));
		self.register(id, heartRate);
	}, "/miband").permanent_(true)
};

h.getBus = {
	arg self, busnum = 0;
	self.buses.values@@busnum;
};

h.beat = {
	arg self, num = 0, default = 60;
	self.heartrates.values@@num ? default;
};

h.register={
	arg self, id, heartRate;
	if(self.buses[id].isNil){
		self.buses[id]=Bus.control(s,1);
	};
	self.buses[id].set(heartRate);
	self.heartrates[id]=heartRate;
}
);

//OSCdef.trace(false, true)
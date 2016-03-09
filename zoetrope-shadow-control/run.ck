// master.ck
// Eric Heep

// communication classes
Machine.add(me.dir() + "/Handshake.ck");
Machine.add(me.dir() + "/HandshakeID.ck");
Machine.add(me.dir() + "/Puck.ck");

// midi class
// Machine.add(me.dir() + "/NanoKontrol2.ck");

// main program
3.0::second => now;
// Machine.add(me.dir() + "/nanoShadow.ck");
// Machine.add(me.dir() + "/shadow-tester.ck");
Machine.add(me.dir() + "/shadow-script.ck");

HandshakeID talk;
2.5::second => now;

// initial handshake between ChucK and Arduinos
talk.talk.init();
2.5::second => now;

Puck p;
p.init(0);

8 => int NUM_LEDS;

for (0 => int i; i < NUM_LEDS; i++) {
    p.send(i, 0, 0, 0);
}

p.send(4, 0, 0, 255);

while (true) {
    for (0 => int i; i < NUM_LEDS; i++) {

    }
    1::ms => now;
}

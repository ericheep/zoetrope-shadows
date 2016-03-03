// give it some time to breathe
HandshakeID talk;
2.5::second => now;

// initial handshake between ChucK and Arduinos
talk.talk.init();
2.5::second => now;

// Puck assignments to ports
Puck p;
p.init(0);

// variables you are free to change!
8 => int NUM_LEDS;

// colors, from 0-1023
0 => int lowHue;
1023 => int highHue;

// midi class
NanoKontrol2 n;

dur cycleSpeed;

int hue[NUM_LEDS];
int sat[NUM_LEDS];
int val[NUM_LEDS];
int baseVal[NUM_LEDS];

// overall brightness and hue
fun void color() {
    for (0 => int i; i < NUM_LEDS; i++) {
        n.knob[0] => hue[i];
        n.slider[1] => sat[i];
        n.knob[1] => baseVal[i];
    }
}

// shadow spectrum
fun void cycle() {
    n.slider[0]::ms + 1::ms => cycleSpeed;
}

fun int convert(float input, float scale) {
    return Math.floor(input/127.0 * scale) $ int;
}

fun void updateColors() {
    for (0 => int i; i < NUM_LEDS; i++) {
        p.send(i, convert(hue[i], lowHue + highHue),
                     convert(sat[i], 255),
                     convert(val[i], 255));
    }
}

fun void cycleLED() {
    int mod;
    while (true) {
        (mod + 1) % NUM_LEDS => mod;

        for (0 => int i ;i < NUM_LEDS; i++) {
            if (i == mod) {
                127 => val[i];
            }
            else {
                baseVal[i] => val[i];
            }
        }

        cycleSpeed => now;
    }
}


spork ~ cycleLED();

while (true) {
    color();
    cycle();
    updateColors();
    (1.0/30.0)::second => now;
}

HandshakeID talk;
2.5::second => now;

// initial handshake between ChucK and Arduinos
talk.talk.init();
2.5::second => now;

Puck p;
p.init(0);

12 => int NUM_LEDS;

float hue[NUM_LEDS];
float sat[NUM_LEDS];
float val[NUM_LEDS];

0.0 => float colorOffset;

float easeHue[NUM_LEDS];
float easeSat[NUM_LEDS];
float easeVal[NUM_LEDS];
float muteVal[NUM_LEDS];

(1.0/60.0)::second => dur frameRate;

for (0 => int i; i < NUM_LEDS; i++) {
    1.0 => val[i];
    1.0 => easeVal[i];
    1.0 => sat[i];
    1.0 => easeSat[i];
}

// changes which sides are connected
fun void sides() {
    <<< "sides()", "" >>>;
    // parameters
    0.25 => float chance;
    // in seconds
    [18.0, 30.0] @=> float phaseTimes[];

    int low, high;
    while (true) {
        if (chance < Math.random2f(0.0, 1.0)) {
            Math.random2(0, NUM_LEDS) => low;
            (low + Math.random2(3, 8)) % NUM_LEDS => high;
            for (0 => int i; i < NUM_LEDS; i++) {
                0.0 => val[i];
            }
            if (low > high) {
                low => int temp;
                high => low;
                temp => high;
            }
            for (low => int i; i < high; i++) {
                1.0 => val[i];
            }
        }
        else {
            for (0 => int i; i < NUM_LEDS; i++) {
                1.0 => val[i];
            }
        }
        Math.random2f(phaseTimes[0], phaseTimes[1])::second => now;
    }
}

// changes the palette, should smooth to them
fun void colorRange() {
    <<< "colorRange()", "" >>>;
    // parameters
    0.6 => float maxRange;
    // in seconds
    [24.0, 49.0] @=> float phaseTimes[];
    // color range
    float low, high;
    while (true) {
        Math.random2f(0.0, 1.0) => colorOffset;
        Math.random2f(0.0, 1.0) => low;
        (low + Math.random2f(0.0, maxRange)) % 1.0 => high;
        if (low > high) {
            low => float temp;
            high => low;
            temp => high;
        }
        for (0 => int i; i < NUM_LEDS; i++) {
            Math.random2f(low, high) => easeHue[i];
        }
        <<< low, high >>>;
        Math.random2f(phaseTimes[0], phaseTimes[1])::second => now;
    }
}

fun void easing() {
    <<< "easing()", "" >>>;
    0.0001 => float increment;

    while (true) {
        for (0 => int i; i < NUM_LEDS; i++) {
            if (hue[i] < easeHue[i]) {
                hue[i] + increment => hue[i];
            }
            else if (hue[i] > easeHue[i]) {
                hue[i] - increment => hue[i];
            }
            if (val[i] < easeVal[i]) {
                val[i] + increment => val[i];
            }
            else if (val[i] > easeVal[i]) {
                val[i] - increment => val[i];
            }
        }
        frameRate => now;
    }
}

fun void flicker() {
    <<< "flicker()", "" >>>;
    1.0 => float maxRange;
    // in seconds
    [1.0/60.0, 8.0/60.0] @=> float flickerTimes[];
    // in seconds
    [16.0, 40.0] @=> float phaseTimes[];

    while (true) {
        Math.random2f(phaseTimes[0], phaseTimes[1])::second => dur phaseTime;
        Math.random2(0, 2) => int which;

        now => time start;

        // speed up/ slow down
        if (which == 0) {
            Math.random2f(0.0, 0.5) => float brightness;
            Math.random2f(flickerTimes[0], flickerTimes[1])::second => dur flickerTime;

            Math.random2(0, 1) => int direction;

            while (now < phaseTime + start) {
                for (0 => int i; i < NUM_LEDS; i++) {
                    for (0 => int j; j < NUM_LEDS; j++) {
                        if (i == j) {
                            brightness => muteVal[j];
                        }
                        else {
                            1.0 => muteVal[j];
                        }
                    }
                    if (direction == 0) {
                        if (flickerTime - 1::ms > frameRate) {
                            flickerTime - 1::ms => flickerTime;
                        }
                    }
                    if (direction == 1) {
                        if (flickerTime + 1::ms > frameRate) {
                            flickerTime + 1::ms => flickerTime;
                        }
                    }
                    flickerTime => now;
                }
            }
        }

        // random
        if (which == 1) {
            while (now < phaseTime + start) {
                for (0 => int i; i < NUM_LEDS; i++) {
                    1.0 => muteVal[i];
                }
                0.0 => muteVal[Math.random2(0, NUM_LEDS - 1)];
                Math.random2f(flickerTimes[0], flickerTimes[1])::second => now;
            }
        }
        // do nothing
        if (which == 2) {
            for (0 => int i; i < NUM_LEDS; i++) {
                1.0 => muteVal[i];
            }

            phaseTime => now;
        }
    }
}

fun void brightnessRange() {
    // in seconds
    // parameters
    0.6 => float maxRange;
    // in seconds
    [24.0, 37.0] @=> float phaseTimes[];
    // color range
    float low, high;

    while (true) {
        Math.random2f(0.0, 1.0) => low;
        (low + Math.random2f(0.0, maxRange)) % 1.0 => high;
        if (low > high) {
            low => float temp;
            high => low;
            temp => high;
        }
        for (0 => int i; i < NUM_LEDS; i++) {
            Math.random2f(low, high) => easeHue[i];
        }
        Math.random2f(phaseTimes[0], phaseTimes[1])::second => now;
    }

}


fun int convert(float input, float scale) {
    return Math.floor(input * scale) $ int;
}

fun void updateColors() {
    for (0 => int i; i < NUM_LEDS; i++) {
        p.send(i, convert((hue[i] + colorOffset) % 1.0, 1027),
                  convert(sat[i], 255),
                  convert(val[i] * muteVal[i], 255));
    }
}

spork ~ easing();
spork ~ colorRange();
spork ~ brightnessRange();
spork ~ sides();
spork ~ flicker();

while (true) {
    updateColors();
    frameRate => now;
}

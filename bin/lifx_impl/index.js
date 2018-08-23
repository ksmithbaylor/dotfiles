const Lifx = require('node-lifx').Client;

const client = new Lifx();

const common = [7500, 500];

// Hue, Saturation, Brightness, Kelvin, Duration
const colors = {
  blue: [230, 100, 100],
  baylor: [125, 100, 100],
  normal: [0, 0, 100],
  red: [0, 100, 100],
};

let color = null;
let targetColor = null;

if (process.argv.length >= 5) {
  color = [...process.argv.slice(2).map(x => parseInt(x, 10))];
  while (color.length < 5) {
    color.push(common[color.length - 3]);
  }
  targetColor = `custom (${color.join(', ')})`;
} else if (process.argv.length === 3) {
  targetColor = process.argv[2];
  if (targetColor !== 'off') {
    if (!(targetColor in colors)) {
      console.log(`"${targetColor}" is not a valid color.`);
      process.exit(1);
    }
    color = [...colors[targetColor], ...common];
  }
} else {
  console.log('Usage:');
  console.log('  lifx <color>');
  console.log('       Color: ' + Object.keys(colors).join(', ') + ', off');
  console.log();
  console.log('  lifx <hue> <saturation> <brightness> <kelvin> <duration>');
  console.log();
  console.log('         Hue: 0-360');
  console.log('  Saturation: 0-100');
  console.log('  Brightness: 0-100');
  console.log('      Kelvin: {25,30,32,35,40,45,50,55,60,65,70,75,80,85,90}00');
  console.log('    Duration: 0-inf, in ms');
  process.exit(1);
}

const totalLights = 2;
let lightsSoFar = 0;

const whenDone = () => {
  lightsSoFar++;
  if (lightsSoFar === totalLights) {
    console.log('Lights are now ' + targetColor);
    process.exit();
  }
};

client.on('light-new', light => {
  if (targetColor === 'off') {
    light.off(500, whenDone);
  } else {
    light.on(500, () => {
      light.color(...color, whenDone);
    });
  }
});

client.init();

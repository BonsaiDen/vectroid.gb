console.log('angle_table:');
for(let x = 0; x < 16; x++) {
    let line = '    DB ';
    let values = [];
    for(let i = 0; i < 256; i++) {
        let a = (2 * Math.PI / 256) * i;
        let v = Math.sin(a) * 127;
        values.push(Math.min(Math.round((v * (x + 1) / 128)), x));
    }
    // console.log(values[64], values[(64 + 64) % 256]);
    console.log(line + values.join(', '));
}

function sqrt(x, y) {
    return Math.round(Math.sqrt(x * x + y * y));
}


{
    console.log('sqrt_table:');
    let values = [];
    for(let x = 0; x < 16; x++) {
        for(let y = 0; y < 16; y++) {
            values.push(sqrt(x, y));
        }
    }
    console.log('    DB ' + values.join(', '));

}

function atan2(y, x) {
    let r = ((((Math.PI + Math.atan2(y, x)) / (Math.PI * 2)) * 256 - 128) + 256) % 256;
    return Math.round(r);
}

{
    console.log('atan2_table:');
    let values = [];
    // TODO offset access by 16
    for(let x = -8; x < 8; x++) {
        for(let y = -8; y < 8; y++) {
            values.push(atan2(y, x));
        }
    }
    console.log('    DB ' + values.join(', '));
}


function angleTable() {
    console.log('angle_table:');
    for(let x = 1; x <= 16; x += 1) {
        let line = '    DB ';
        let values = [];
        for(let i = 0; i < 256; i++) {
            let a = (2 * Math.PI / 256) * i;
            let v = Math.sin(a) * 127;
            let l = (v * (x + 1) / 128);
            if (l < 0) {
                values.push(Math.min(Math.ceil(l), x));

            } else {
                values.push(Math.min(Math.floor(l), x));
            }
        }
        // console.log(values[64], values[(64 + 64) % 256]);
        console.log(line + values.join(', '));
    }
    //console.log(128 / 2 * 64);
}

function atan2Table() {
    function atan2(y, x) {
        let r = ((((Math.PI + Math.atan2(y, x)) / (Math.PI * 2)) * 256 - 128) + 256) % 256;
        console.log(x, y, r);
        return Math.round(r);
    }

    console.log('atan2_table:');
    let values = [];
    // TODO offset access by 16
    for(let y = 0; y < 2; y++) {
        for(let x = 0; x < 16; x++) {
            values.push(atan2(y, x));
        }
    }
    console.log('    DB ' + values.join(', '));
    console.log(values[0x80]);
}

function tamilTable() {
    // See https://math.stackexchange.com/a/1352361
    let values = [];
    for(let x = 0; x < 128; x++) {
        values.push(Math.round(x * 0.871079));
    }

    for(let y = 0; y < 128; y++) {
        values.push(Math.round(y * 0.509221));
    }
    console.log('tamil_table:');
    console.log('    DB ' + values.join(', '));
}

function sqrtLengthTable() {
    // See https://math.stackexchange.com/a/1352361
    let values = [];
    for(let x = 0; x < 16; x++) {
        for(let y = 0; y < 16; y++) {
            values.push(Math.floor(Math.sqrt(x * x + y * y)));
        }
    }
    console.log('sqrt_table:');
    console.log('    DB ' + values.join(', '));
}

angleTable();
sqrtLengthTable();
//atan2Table();

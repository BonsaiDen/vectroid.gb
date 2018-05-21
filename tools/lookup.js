function angleTable() {
    console.log('angle_table:');
    for(let x = 1; x <= 32; x += 1) {
        let line = '    DB ';
        let values = [];
        for(let i = 0; i < 64; i++) {
            let a = (2 * Math.PI / 256) * i;
            let v = Math.sin(a) * 127;
            let l = (v * (x + 1) / 128);
            if (l < 0) {
                values.push(Math.min(Math.ceil(l), x));

            } else {
                values.push(Math.min(Math.floor(l), x));
            }
        }
        console.log(line + values.join(', '));
    }
}

function atan2Table() {
    function atan2(y, x) {
        let r = ((((Math.PI + Math.atan2(y, x)) / (Math.PI * 2)) * 256 - 128) + 256) % 256;
        return Math.round(r);
    }

    console.log('atan2_table:');
    let values = [];
    // TODO offset access by 16
    for(let y = 0; y < 32; y++) {
        for(let x = 0; x < 32; x++) {
            values.push(atan2(y, x));
        }
    }
    console.log('    DB ' + values.join(', '));
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
    let values = [];
    for(let x = 0; x < 32; x++) {
        for(let y = 0; y < 32; y++) {
            values.push(Math.floor(Math.sqrt(x * x + y * y)));
        }
    }
    console.log('sqrt_table:');
    console.log('    DB ' + values.join(', '));
}

function asciiTable() {

    const characters = [
        ' 0123456789:;<=>',
        ' !"#$%&`()*+,-./',
        '?@ABCDEFGHIJKLMN',
        'OPQRSTUVWXYZ[\\]^',
        '_`abcdefghijklmn',
        'opqrstuvwxyz{|}~'

    ].join('');

    const ascii = '.'.repeat(256).split('').map((_, i) => String.fromCharCode(i));
    const values = ascii.map((c) => {
        const i = characters.indexOf(c);
        if (i === -1) {
            return '$00';

        } else {
            let c = i.toString(16).toUpperCase();;
            if (c.length < 2) {
                c = `0${c}`;
            }
            return `$${c}`;
        }
    });

    console.log('text_table:');
    const row = [];
    values.forEach((v) => {
        row.push(v);
        if (row.length === 16) {
            console.log('    DB ' + row.join(', '));
            row.length = 0;
        }
    });

}

angleTable();
//sqrtLengthTable();
//atan2Table();

//asciiTable();


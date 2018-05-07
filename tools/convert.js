// Dependencies ---------------------------------------------------------------
var path = require('path'),
    Promise = require('bluebird'),
    lib = require('./lib');


// Setup Data Paths -----------------------------------------------------------
lib.IO.setSource(path.join(process.cwd(), process.argv[2]));
lib.IO.setDest(path.join(process.cwd(), process.argv[3]));


// Convert Tuff Data Files ----------------------------------------------------
Promise.all([
    lib.Tileset('ui.bg.png'),

]).then(function() {
    console.log('Complete!');

}).error(function(err) {
    console.error(err.toString().red);
    process.exit(1);
});



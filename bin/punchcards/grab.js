var page = require('webpage').create();
var system = require('system');
var url = 'https://github.com/' + system.args[1] + '/' + system.args[2] + '/graphs/punch-card';
page.clipRect = { top: 190, left: 0, height: 526, width: 920 };

page.open(url, function () {
  setTimeout(function() {
    page.render('punchcard.png');
    phantom.exit();
  }, 2000);
});

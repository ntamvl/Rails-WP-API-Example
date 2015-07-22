var page = new WebPage();
var system = require('system');
var address = system.args[1];
page.open(address, function (status) {
        just_wait();
});

function just_wait() {
    setTimeout(function() {
            // page.render('screenshot2-2.png');
            console.log(page.content);
            phantom.exit();
    }, 7000);
}

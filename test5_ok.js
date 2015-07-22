var page = new WebPage();
page.open('http://kissanime.com/AnimeList', function (status) {
        just_wait();
});

function just_wait() {
    setTimeout(function() {
            // page.render('screenshot2-2.png');
            console.log(page.content);
            phantom.exit();
    }, 7000);
}

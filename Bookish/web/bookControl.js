function previousChapterIfAtStart() {
    if (window.scrollY > 0) {
        window.bewk.log("not at start of the page");
        return true;
    }

    window.bewk.previousChapter();
    return false;
}

function nextChapterIfAtEnd() {
    var scrollMaxY = document.documentElement.scrollHeight - document.documentElement.clientHeight;
    window.bewk.log("Window scrollY: " + window.scrollY + " max scrollY: " + scrollMaxY);
    if (window.scrollY < scrollMaxY) {
        window.bewk.log("not at the end of the page");
        return true;
    }

    window.bewk.nextChapter();
    return false;
}

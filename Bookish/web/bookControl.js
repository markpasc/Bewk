function handleWebKeypress(e) {
    if (e.metaKey || e.ctrlKey || e.shiftKey) {
        window.bewk.log("some meta key is down");
        return true;
    }
    window.bewk.log(e.keyCode);
    if (e.keyCode != 32) {
        window.bewk.log("some key besides space was hit");
        return true;
    }

    var scrollMaxY = document.documentElement.scrollHeight - document.documentElement.clientHeight;
    window.bewk.log("Window scrollY: " + window.scrollY + " max scrollY: " + scrollMaxY);
    if (window.scrollY < scrollMaxY) {
        window.bewk.log("not at the end of the page");
        return true;
    }

    window.bewk.nextChapter();
    return false;
}

document.addEventListener('keypress', handleWebKeypress);

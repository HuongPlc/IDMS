function chooseImg() {
    try {
        var element = document.getElementById("lbtLogin");
        element.addEventListener("click", function() {
                    varmessageToPost = {'ButtonId':'clickMeButton'};
                    window.webkit.messageHandlers.haha.postMessage(messageToPost);
        });
    } catch(err) {
            console.log('The native context does not exist yet');
    }
}


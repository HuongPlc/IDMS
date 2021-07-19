func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    print("User message got")
  print(message.name) // prints nativeProcess string
    if(message.body is String){
         print(message.body) // prints the data that is sent from javascript
    }
}

// Code based on:
// http://developer.apple.com/internet/webcontent/xmltransformations.html
//
var xhtml = "http://www.w3.org/1999/xhtml";
var allItems = document.getElementsByTagName("a");
for (var i=0;i<allItems.length;i++)
{
    var itemElm   = allItems[i];
    var titleText = itemElm.firstChild.nodeValue;
    var linkURL   = itemElm.firstChild.nodeValue;

    var newLinkElm = document.createElementNS(xhtml,"a");
    var txtNode = document.createTextNode(titleText);
    // NOTE: the original code (cf link) had the namespace argument
    // (the first arg) set to xhtml, but that made the link non-
    // functional. Setting it to undefined made it work in Safari and
    // Firefox.
    newLinkElm.setAttributeNS("","href",linkURL);
    newLinkElm.appendChild(txtNode);

    itemElm.parentNode.replaceChild(newLinkElm,itemElm);

}

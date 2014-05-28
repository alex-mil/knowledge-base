1. dom.parent("div").css("overflow", "auto"); // adds horizontal scroll bar if needed

2. inputs = $(newHtml).find('.__photo_info'); // cleaning up array properly and creating object from JSON

3. // Reload the whole document with new HTML
   var _newDoc = document.open("text/html", "replace");
   _newDoc.write(<some html>);
   _newDoc.close();

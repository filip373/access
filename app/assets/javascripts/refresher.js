$(document).ready(function() {
  var elem = $('.refresher');
  if(elem.length > 0) {
    var seconds = 10;
    setInterval(function() {
      elem.html("Wait " + seconds + " seconds or ");
      seconds--;
      if(seconds == 0) {
        location.reload();
      }
    }, 1000);
  }
});

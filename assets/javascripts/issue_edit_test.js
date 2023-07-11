console.log('The JavaScript code has been rendered!');
if (typeof $.fn.select2 === 'undefined') {
  $.getScript('https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.13/js/select2.full.min.js', function() { 
    var link = document.createElement('link');
    link.href = 'https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.6-rc.0/css/select2.min.css';
    link.rel = 'stylesheet';
    link.type = 'text/css';
    document.head.appendChild(link);
  });
}
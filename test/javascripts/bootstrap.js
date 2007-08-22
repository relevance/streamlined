if (document.URL.match('localhost:4711')) {
  base = '/files/public/';
} else {
  base = '../../files/public/';
}
var scripts = ['windows_js/javascripts/prototype.js',
               'windows_js/javascripts/effects.js',
               'windows_js/javascripts/window.js',
               'overlib/overlib.js',
               'javascripts/streamlined.js'];
for (var n in scripts) {
  document.write("<script type='text/javascript' src='" + base + scripts[n] + "'></script>");  
}

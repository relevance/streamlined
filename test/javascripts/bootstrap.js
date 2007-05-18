if (document.URL.match('localhost:4711')) {
  base = '/files/';
} else {
  base = '../../files/';
}
var scripts = ['windows_js/javascripts/prototype.js',
               'windows_js/javascripts/effects.js',
               'windows_js/javascripts/window.js',
               'overlib/overlib.js',
               'streamlined.js'];
for (var n in scripts) {
  document.write("<script type='text/javascript' src='" + base + scripts[n] + "'></script>");  
}

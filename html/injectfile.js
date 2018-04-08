//HACK: inject file name
function getQueryParams(qs) {
  qs = qs.split("+").join(" ");
  var params = {},
      tokens,
      re = /[?&]?([^=]+)=([^&]*)/g;
  while (tokens = re.exec(qs)) {
      params[decodeURIComponent(tokens[1])]
          = decodeURIComponent(tokens[2]);
  }
  return params;
}

var fileUrl=getQueryParams(window.location.hash)["#file"];
console.log("Running using  "+window.location.hash)

if (typeof fileUrl !== "undefined" && fileUrl !== null) {
  jQuery.get(fileUrl).then(function(text, status, xhr){
    //FIXME: Uncaught TypeError: k is not a function
    webppl.run(text, function(s,x) {result = x})
  });
}

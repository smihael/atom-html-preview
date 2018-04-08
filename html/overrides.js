
  var addResult = function() {
    //return  document.getElementById('results');
    $('#results').append( document.createElement('result') )
    return _.last($('result'))
  }

  //HACK: we overwrite webppl-viz dependencies from webppl-editor here
  //TODO: long term sollution is to implement renderSpec for runningInBrowser == true case in webppl-viz
  var wpEditor = {};
  wpEditor.makeResultContainer = addResult;

  //HACK: hijack display to show output
  (function(){
    var oldLog = console.log;
    console.log = function (message) {
      var res = addResult();
         res.append(message);
      oldLog.apply(console, arguments);
    };
  })();

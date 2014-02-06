(function () {
  window.util = {};

  var dataMap = {};
  util = {
    buildMap: function (langs) {
      // Compute a map from name to node.
      langs.forEach(function(n) {
        dataMap[n.name] = n;
      });
    },

    getLangByName: function (name) {
      return dataMap[name];
    },

    escapeName: function (name) {
      return name.replace(' ', '-')
        .replace(/\+/g, '_plus')
        .replace('#', 'sharp');
    },
  };
})();

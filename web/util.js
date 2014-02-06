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

    toggleActiveNode: function () {
      var state = this._active = !this._active;

      var data = this.__data__,
          name = util.escapeName(data.name),
          related = [];

      d3.selectAll('path.source-' + name)
        .classed("show", state);

      d3.selectAll('path.target-' + name)
        .classed("show", state);

      d3.select(node)
        .classed('active', state);

      if (data.influenced) {
        data.influenced.forEach(function (name) {
          d3.select('#' + util.escapeName(name)).classed('related', state);
        });
      }

      if (data.influenced_by) {
        data.influenced_by.forEach(function (name) {
          d3.select('#' + util.escapeName(name)).classed('related', state);
        });
      }
    },
  };
})();

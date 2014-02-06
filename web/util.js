(function () {
  window.util = {};

  var dataMap = {};
  _.templateSettings.variable = "data";

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

    printScreen: function (str) {
      return _.map(str.split('_'), function (word) {
        return word.charAt(0).toUpperCase() + word.slice(1);
      }).join(' ');
    },

    renderTmpl: function (lang) {
      var tmpl = _.template(document.getElementById('panel_tmpl').innerHTML);
      var panel = tmpl(lang);
      document
        .getElementById('panel_container')
        .innerHTML = panel;
    }
  };
})();

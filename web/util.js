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

    inactivateAllNodes: function () {
      d3.selectAll('g.lang').each(function (lang) {
        if (lang.active) {
          util.toggleActiveNode.apply(this);
        }
      });
    },

    toggleActiveNode: function () {
      console.log(this.__data__);
      var state = this.__data__.active = !this.__data__.active;

      var data = this.__data__,
          name = util.escapeName(data.name),
          related = [];

      d3.selectAll('path.source-' + name)
        .classed("show", state);

      d3.selectAll('path.target-' + name)
        .classed("show", state);

      d3.select(this)
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

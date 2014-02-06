function printName (name) {
  return name
    .replace(' ', '-')
    .replace(/\+/g, '_plus')
    .replace('#', 'sharp');
}

function mouseOver () {
  var data = this.__data__,
      related = [],
      name = printName(data.name);

  d3.selectAll('path.source-' + name)
    .classed("show", true);

  d3.selectAll('path.target-' + name)
    .classed("show", true);

  d3.select(this)
    .classed('active', true);

  if (data.influenced) {
    data.influenced.forEach(function (name) {
      d3.select('#' + printName(name)).classed('related', true);
    });
  }

  if (data.influenced_by) {
    data.influenced_by.forEach(function (name) {
      d3.select('#' + printName(name)).classed('related', true);
    });
  }
}

function mouseLeave () {
  var data = this.__data__,
      name = printName(data.name);

  d3.selectAll('path.source-' + name)
    .classed("show", false);

  d3.selectAll('path.target-' + name)
    .classed("show", false);

  d3.select(this)
    .classed('active', false);

  if (data.influenced) {
    data.influenced.forEach(function (name) {
      d3.select('#' + printName(name)).classed('related', false);
    });
  }

  if (data.influenced_by) {
    data.influenced_by.forEach(function (name) {
      d3.select('#' + printName(name)).classed('related', false);
    });
  }
}

function reducedToLinks (langs, type) {
  var map = {},
  result = [];

  // Compute a map from name to node.
  langs.forEach(function(n) {
    map[n.name] = n;
  });

  // For each import, construct a link from the source to target node.
  langs.forEach(function(n) {
    if (n[type]) n[type].forEach(function(i) {
      result.push({source: map[n.name], target: map[i]});
    });
  });

  return result;
}

function draw (data) {
  var dimention = { w: 800, h: 3000 },
      margins = { left: 100, top: 80, bottom: 80, right: 20 },
      circleR = 5;

  var timeScale = d3.time.scale()
    .range([dimention.h - margins.bottom, margins.top])
    .domain(d3.extent(_.map(data, function (lang) {
      return new Date(lang['appeared_in']);
    })));

  var horizontalScale = d3.scale.linear()
    .range([dimention.w - margins.right, margins.left])
    .domain([-2, 6]); // -2 to avoid collaspe with the bottom axie line

  var timeAxis = d3.svg.axis()
    .scale(timeScale)
    .orient('left');

  // draw container
  d3.select("body")
    .append("div")
      .attr('id', 'chart_container');

  // draw the chart canvas
  var chart = d3.select('#chart_container')
    .append('svg')
      .attr("width", dimention.w)
      .attr("height", dimention.h)
    .append("g")
      .attr("id","chart");

  // draw language points
  var groupByAppear = _.groupBy(data, function (lang) {
    return lang['appeared_in'];
  });

  function xPos (lang) {
    return horizontalScale(groupByAppear[lang['appeared_in']].indexOf(lang));
  }

  var langs = chart.append("g")
  // show panel
    .attr('class', 'lang_container')
    .selectAll('g.lang')
    .data(data)
    .enter()
    .append('svg:g')
      .attr('class', 'lang')
      .attr('id', function (d) {
        return printName(d.name);
      })
    .on('mouseenter', mouseOver)
    .on('mouseleave', mouseLeave);

  langs.append('circle')
    .attr('fill', function (d) { return d.color; })
    .attr('r', circleR)
    .attr('cy', function (d) {
      d.y = timeScale(new Date(d['appeared_in']));
      return d.y;
    })
    .attr('cx', function (d) {
      // distribute langs appeared in the same year
      d.x = xPos(d);
      return d.x;
    });

  langs.append('text')
    .text(function (d) { return d['name']; })
    .attr('text-anchor','end')
    .attr('class', 'lang_name')
    .attr('transform', function (d) {
      return "translate(-5, 10)" + "rotate (-55," + d.x + "," + d.y + ")";
    })
    .attr('x', function (d) { return d.x; })
    .attr('y', function (d) { return d.y; })
    .attr('fill', function (d) { return d.color; });

  // draw influenced path
  var influencedLinks = reducedToLinks (data, 'influenced');

  var line = d3.svg.line()
      .tension(0.85)
      .x(function(d) { return d.x; })
      .y(function(d) { return d.y; })
      .interpolate("basis");

  var path = chart.append('g')
      .attr('class', 'path_container')
    .selectAll("path.link")
      .data(influencedLinks)
    .enter().append("path")
      .attr("class", function(d) { return "link source-" + printName(d.source.name) + " target-" + printName(d.target.name); })
      .attr('stroke', function (d) { return d.source.color; })
      .attr("d", function(d) {
        var source = d.source,
            target = d.target,
            middle = {x : target.x, y : source.y};

        return line([source, middle, target]);
      });

  // draw x axis
  chart.append("g")
    .attr("class", "y axis")
    .attr("transform", "translate(" + margins.left + ",0)")
    .call(timeAxis);
}

d3.json('lang.json', draw);

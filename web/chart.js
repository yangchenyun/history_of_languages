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
  var dimention = { w: 3000, h: 600 },
      margins = { left: 80, top: 20, bottom: 20, right: 20 },
      circleR = 5;

  var timeScale = d3.time.scale()
    .range([margins.left, dimention.w - margins.right])
    .domain(d3.extent(_.map(data, function (lang) {
      return new Date(lang['appeared_in']);
    })));

  var verticalScale = d3.scale.linear()
    .range([dimention.h - margins.bottom, margins.top])
    .domain([-1, 5]); // -1 to avoid collaspe with the bottom axie line

  var timeAxis = d3.svg.axis()
    .scale(timeScale);

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

  // draw x axis
  chart.append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(" + 0 + "," + (dimention.h - margins.bottom) + ")")
    .call(timeAxis);

  // draw language points
  var groupByAppear = _.groupBy(data, function (lang) {
    return lang['appeared_in'];
  });

  function yPos (lang) {
    return verticalScale(groupByAppear[lang['appeared_in']].indexOf(lang));
  }

  var langs = chart.append("g")
    .attr('class', 'lang_container')
    .selectAll('g.lang')
    .data(data)
    .enter()
    .append('svg:g')
      .attr('class', 'lang');

  langs.append('circle')
    .attr('fill', function (d) { return d.color; })
    .attr('r', circleR)
    .attr('cx', function (d) {
      d.x = timeScale(new Date(d['appeared_in']));
      return d.x;
    })
    .attr('cy', function (d) {
      // distribute langs appeared in the same year
      d.y = yPos(d);
      return d.y;
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
      .attr("class", function(d) { return "link source-" + d.source.name + " target-" + d.target.name; })
      .attr('stroke', function (d) { return d.source.color; })
      .attr("d", function(d) {
        var source = d.source,
            target = d.target,
            middle = {x : target.x, y : source.y};

        return line([source, middle, target]);
      });

}

d3.json('lang.json', draw);
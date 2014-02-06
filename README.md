# History Of Languages
[site](http://www.yangchenyun.com/history_of_languages/)

This repo is a visualisation of language history.

*master branch* contains crawler to fetch data from Wikipedia and data cleaner
to format and integrit data.

*gh-pages branch* contains visulisation based on d3.js to show the history of languages.

# Cralwer Details
For master branch.
```ruby
gem install
rake test
```

`lib/visitor.rb` is an object take cares of page crawling, and it avoids infinite loops.

`lib/infobox.rb` is an object to fetch related data from each Wikipedia page.

`script/crawler.rb` uses the above two scripts to fetch raw data.

`script/cleanup_data.rb` uses to throw away unnecessary data and format data to satisfy the requirement in 'test/data_integrity_test.rb' (some manual cleanup is also required).

For gh-pages branch:
```bash
bower install
python -m SimpleHTTPServer 8080
```

# Visulisation Details
`d3` is used to visualize the data, including data influency, data relationships and appearing year.

All drawing is straight forward in `chart.js`, and utility are stored in a `util.js` which expose a global variable `util` to hold all functions.

`underscore` is used across scripts and render templates.
require 'uri'
require 'mechanize'

class InfoBox
  DOMAIN = 'http://en.wikipedia.org/'

  attr_reader :result

  def initialize(link)
    @result = {}
    @agent = Mechanize.new
    @infobox = @agent.get(URI.join(DOMAIN, link)).search('.infobox')
    @rows = @infobox.search('tr:has(th)')

    # parse name
    @result['name'] = @infobox.search('caption').text()

    # parse properties
    @rows.each do |tr|
      k = tr.search('th')[0].content.gsub(/[^a-zA-Z_\s]/, '').gsub(' ', '_').downcase
      v = tr.search('td')[0].content
      @result[k] = v
    end

    # parse languages links
    @result['influenced_by_links'] = @rows.find { |r| r.content['Influenced by'] }
      .search('td > a')
      .map { |a| a.attribute('href').text }

    @result['influenced_links'] = @rows.find { |r| r.content[/Influenced\s*$/] }
      .search('td > a')
      .map { |a| a.attribute('href').text }

    # clean up language names
    @result['influenced'] = @result['influenced'].gsub(/\[\d\]|\s+/, '').split(',')
    @result['influenced_by'] = @result['influenced_by'].gsub(/\[\d\]|\s+/, '').split(',')

    # clean up appeared_in
    @result['appeared_in'] = @result['appeared_in'][/\d\d\d\d/]

    # parse_paradigms
    @result['paradigms'] = @result['paradigms'].gsub(/[-\w]+:|\s+/, '').split(',')
  end
end
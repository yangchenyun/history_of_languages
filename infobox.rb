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

    # clean up language names and parse language links
    if @result['influenced']
      @result['influenced'] = @result['influenced'].gsub(/\[\d\]|\s+/, '').split(',')
      @result['influenced_links'] = @rows.find { |r| r.content[/Influenced\s*$/] }
        .search('td > a')
        .map { |a| a.attribute('href').text }
    end

    if @result['influenced_by']
      @result['influenced_by'] = @result['influenced_by'].gsub(/\[\d\]|\s+/, '').split(',')
      @result['influenced_by_links'] = @rows.find { |r| r.content['Influenced by'] }
        .search('td > a')
        .map { |a| a.attribute('href').text }
    end

    # clean up appeared_in
    @result['appeared_in'] = @result['appeared_in'][/\d\d\d\d/]

    # parse_paradigms
    @result['paradigms'] = @result['paradigms'].gsub(/[-\w]+:/, '').split(/,/).map(&:strip).map(&:downcase)
  end
end
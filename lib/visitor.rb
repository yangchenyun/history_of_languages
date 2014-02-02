class Visitor
  attr_reader :links

  def initialize(*links)
    @links = links.dup
    @visited = {}
  end

  def link_length
    @links.length
  end

  def has_links?
    !@links.empty?
  end

  def pop_link
    @links.pop
  end

  def add_link(link)
    @links.push link unless @links.include?(link) || visited?(link)
  end

  def visited?(link)
    @visited[link]
  end

  def visit
    return unless has_links?
    link = pop_link
    @visited[link] = true
    yield link if block_given?
  end
end
require_relative 'test_helper.rb'
require 'visitor'

class VisitorTest < Minitest::Test
  def setup
    @visitor = Visitor.new('http://google.com')
  end

  def test_init_links_stack
    empty = Visitor.new
    assert_equal [], empty.links

    one = Visitor.new('http://google.com')
    assert_equal ['http://google.com'], one.links

    multiple = Visitor.new('en.wikipedia.org', 'google.com')
    assert_equal ['en.wikipedia.org', 'google.com'], multiple.links
  end

  def test_has_links
    visitor = Visitor.new
    refute visitor.has_links?
    visitor.add_link 'en.wikipedia.org'
    assert visitor.has_links?
  end

  def test_pop_link
    assert_equal 'http://google.com', @visitor.pop_link
    refute @visitor.has_links?, "visitor has #{@visitor.link_length} links."
  end

  def test_link_length
    assert_equal 1, @visitor.link_length
    @visitor.add_link 'en.wikipedia.org'
    assert_equal 2, @visitor.link_length
    @visitor.pop_link
    assert_equal 1, @visitor.link_length
    @visitor.pop_link
    assert_equal 0, @visitor.link_length
  end

  def test_add_link_none_visited_links
    @visitor.add_link 'en.wikipedia.org'
    assert_equal 2, @visitor.links.length
  end

  def test_not_add_link_dup_links
    @visitor.add_link 'http://google.com'
    assert_equal 1, @visitor.links.length
  end

  def test_not_add_link_visited_links
    @visitor.visit
    @visitor.add_link 'http://google.com'
    refute @visitor.has_links?
  end

  def test_visit_mark_link_visited
    refute @visitor.visited? 'http://google.com'
    @visitor.visit
    assert @visitor.visited? 'http://google.com'
  end

  def test_visit_yield_stack_link_to_block
    @visitor.visit do |l|
      assert_equal 'http://google.com', l
    end
  end
end
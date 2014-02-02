require_relative 'test_helper.rb'
require 'fakeweb'
require 'infobox'

[
  'Ruby_(programming_language)',
  'Potion_(programming_language)',
  'Ratfor',
  'AutoHotkey',
  'OpenVera'
].each do |page|
  FakeWeb.register_uri(:get,
      "http://en.wikipedia.org/wiki/#{page}",
      body: File.read(File.expand_path("../stub/#{page}", __FILE__)),
      content_type: "text/html")
end

class InfoBoxTest < Minitest::Test
  def setup
    @ruby_wiki = InfoBox.new('/wiki/Ruby_(programming_language)').result
  end

  def test_parse_caption_reserve_capitalize
    assert_equal 'Ruby', @ruby_wiki['name']
  end

  def test_parse_paradigms
    assert_equal "object-oriented, imperative, functional, reflective".split(", "), @ruby_wiki['paradigms']
  end

  def test_parse_appeard_in
    assert_equal '1995', @ruby_wiki['appeared_in']
  end

  def test_parse_influenced_by_and_influenced
    assert_equal "Ada,C++,CLU,Dylan,Eiffel,Lisp,Perl,Python,Smalltalk".split(','), @ruby_wiki['influenced_by']
    assert_equal "D,Elixir,Falcon,Fancy,Groovy,Ioke,Mirah,Nu,Reia,potion".split(','), @ruby_wiki['influenced']
  end

  def test_parse_influenced_by_and_influenced_links
    assert_equal [
      "/wiki/Ada_(programming_language)",
      "/wiki/C%2B%2B",
      "/wiki/CLU_(programming_language)",
      "/wiki/Dylan_(programming_language)",
      "/wiki/Eiffel_(programming_language)",
      "/wiki/Lisp_(programming_language)",
      "/wiki/Perl",
      "/wiki/Python_(programming_language)",
      "/wiki/Smalltalk"
    ], @ruby_wiki['influenced_by_links']

    assert_equal [
      "/wiki/D_(programming_language)",
      "/wiki/Elixir_(programming_language)",
      "/wiki/Falcon_(programming_language)",
      "/wiki/Fancy_(programming_language)",
      "/wiki/Groovy_(programming_language)",
      "/wiki/Ioke_(programming_language)",
      "/wiki/Mirah_(programming_language)",
      "/wiki/Nu_(programming_language)",
      "/wiki/Reia_(programming_language)",
      "/wiki/Potion_(programming_language)"
      ], @ruby_wiki['influenced_links']
  end

  def test_empty_influenced_or_influenced_by_links
    @potion_wiki = InfoBox.new('/wiki/potion_(programming_language)').result
    assert_nil @potion_wiki['influenced_links']
  end

  def test_empty_paradigms
    @ratfor_wiki = InfoBox.new('/wiki/Ratfor').result
    assert_nil @ratfor_wiki['paradigms']
  end

  def test_empty_appeared_in
    @autohotkey_wiki = InfoBox.new('/wiki/AutoHotkey').result
    assert_nil @autohotkey_wiki['appeared_in']
  end

  def test_empty_infobox
    @openvera_wiki = InfoBox.new('/wiki/OpenVera').result
    assert_equal( { 'name' => 'OpenVera' }, @openvera_wiki )
  end
end

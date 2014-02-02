require_relative 'test_helper.rb'
require 'fakeweb'

require 'infobox'

result = File.read(File.expand_path('../stub/Ruby_programming_language.html', __FILE__))
FakeWeb.register_uri(:get,
    "http://http://en.wikipedia.org/wiki/Ruby_(programming_language)",
    body: result,
    content_type: "text/html")

class InfoBoxTest < Minitest::Test
  def setup
    @infobox = InfoBox.new('/wiki/Ruby_(programming_language)')
  end

  def test_parse_caption_reserve_capitalize
    assert_equal 'Ruby', @infobox['name']
  end

  def test_parse_paradigms
    assert_equal "object-oriented, imperative, functional, reflective".split(", "), @infobox['paradigms']
  end

  def test_parse_appeard_in
    assert_equal 1995, @infobox['appeared_in']
  end

  def test_parse_influenced_by_and_influenced
    assert_equal "Ada,C++,CLU,Dylan,Eiffel,Lisp,Perl,Python,Smalltalk".split(','), @infobox['influenced_by']
    assert_equal "D,Elixir,Falcon,Fancy,Groovy,Ioke,Mirah,Nu,Reia,potion".split(','), @infobox['influenced']
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
    ], @infobox['influenced_by_links']

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
      ], @infobox['influenced_links']
  end

  def test_other_properties
    keys = [
      "designed_by",
      "developer",
      "stable_release",
      "typing_discipline",
      "scope",
      "major_implementations",
      "os",
      "license",
      "usual_filename_extensions",
      "website"
    ]

    values = [
      "Yukihiro Matsumoto",
      "Yukihiro Matsumoto, et al.",
      "2.1.0 (December 25, 2013 (2013-12-25))",
      "duck, dynamic",
      "lexical, sometimes dynamic",
      "Ruby MRI, YARV, Rubinius, MagLev, JRuby, MacRuby, RubyMotion, HotRuby, IronRuby, mruby",
      "Cross-platform",
      "Ruby License or BSD License[7][8]",
      ".rb, .rbw",
      "www.ruby-lang.org"
    ]

    keys.each_with_index do |k, i|
      assert_equal values[i], @infobox[k]
    end
  end
end
require_relative 'test_helper.rb'
require 'json'

LANGS = JSON.parse(File.read(File.expand_path '../../lang.json', __FILE__))
LANG_HASH = {}
LANGS.each { |l| LANG_HASH[l['name']] = l }

class DataIntegrityTest < Minitest::Test
  def test_uniq_lang_names
    assert_equal LANG_HASH.keys.uniq, LANG_HASH.keys
  end

  def test_no_self_influence
    LANGS.map do |l|
      (l['influenced'] || []).dup.concat(l['influenced_by'] || []).each do |il_name|
        refute_equal l['name'], il_name end
    end
  end

  def test_influenced_and_influenced_by_names_exist
    LANGS.map do |l|
      (l['influenced'] || []).dup.concat(l['influenced_by'] || [])
    end.inject(:+).uniq.each do |il_name|
      assert LANG_HASH[il_name]
    end
  end

  def test_influenced_and_influenced_by_are_bidirection
    LANGS.map do |l|
      l_name = l['name']
      (l['influenced'] || []).each do |il_name|
        il = LANG_HASH[il_name]
        assert il['influenced_by'].include?(l_name),
          "#{l_name} influenced #{il_name}, but not stated in #{il_name}"
      end
    end
  end

  def test_one_paradigm_is_assigned

  end

  def test_paradigm_names_are_unique

  end
end

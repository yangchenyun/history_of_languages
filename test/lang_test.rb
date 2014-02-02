require_relative 'test_helper.rb'
require 'lang'

class LangTest < MiniTest::Test
  def setup
    @lang = Lang.new
  end

  def test_setter_getter_methods
    [:name,
     :paradigm,
     :appear_in,
     :designer,
     :developer,
     :influenced_by,
     :influenced].each do |prop|
      obj = Object.new
      @lang.send("#{prop}=", obj)
      assert_equal @lang.send(prop), obj
    end
  end

  def test_influenced_by_influenced_initialized_to_array
    assert_kind_of(Array, @lang.influenced, "#influcned is not an Array")
    assert_kind_of(Array, @lang.influenced_by, "#influcned_by is not an Array")
  end
end
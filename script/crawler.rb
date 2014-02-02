#!/usr/bin/env ruby
require 'ostruct'
require File.expand_path '../../lib/visitor.rb', __FILE__
require File.expand_path '../../lib/infobox.rb', __FILE__

visitor = Visitor.new
visitor.add_link '/wiki/Ruby_(programming_language)'
langs = []

# handle special cases, wrong information etc.
special_case = {
  '/wiki/Joule_(programming_language)' => {
    'name' => 'Joule',
    'paradigms' => 'object-oriented,distributed,dataflow'.split(','),
    'appeared_in' => '1996',
    'designed_by' => 'E. Dean Tribble',
    'typing_discipline' => 'untyped',
    'influenced' => ['E']
  },

  '/wiki/Simula' => {
    'name' => 'Simula',
    'paradigms' => ['object-oriented'],
    'appeared_in' => '1967',
    'designed_by' => 'Ole-Johan Dahl, Kristen Nygaard',
    'typing_discipline' => 'untyped',
    'influenced_by' => ['ALGOL 60'],
    'influenced_by_links' => ['/wiki/ALGOL_60']
  }
}

until !visitor.has_links?
  visitor.visit do |link|
    puts "visiting #{link}..."
    if special_case[link]
      info = special_case[link]
    else
      info = InfoBox.new(link).result
    end
    langs.push info
    info['influenced_by_links'] && info['influenced_by_links'].each do |l|
      visitor.add_link l
    end

    info['influenced_links'] && info['influenced_links'].each do |l|
      visitor.add_link l
    end
  end
end

output = File.new(File.expand_path("../../raw_lang.json", __FILE__), 'w')
output.write(JSON.pretty_generate(langs))
output.close
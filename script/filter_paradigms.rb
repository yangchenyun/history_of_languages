#!/usr/bin/env ruby
# it is used to filterout the low sequence paradigms in raw data
require 'json'
MIN_OCCURENCE = 3
para = JSON.parse(File.read(File.expand_path '../../raw_paradigms.json', __FILE__))
lang = JSON.parse(File.read(File.expand_path '../../lang_pretty.json', __FILE__))

count = []
lang.each do |l|
  next unless l['paradigms']
  pstr = l['paradigms'].join(', ')
  para.each_with_index do |p, i|
    count[i] ||= 0
    count[i] += 1 if pstr[p]
  end
end

filtered = para.zip(count)
  .sort { |a, b| b[1] <=> a[1] }
  .select { |i| i[1] >= MIN_OCCURENCE }
  .map { |i| i[0] }

output = File.new(File.expand_path("../../paradigms.json", __FILE__), 'w+')
output.write(filtered.to_json)
output.close

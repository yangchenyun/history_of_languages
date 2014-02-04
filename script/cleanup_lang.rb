#!/usr/bin/env ruby
# because we are using language names as graph node key and paradigms
# as parent nodes to group languages together, it is important to format
# their appearance in data

# this script aims to filter out and unify the language names and paradigms
# - use github lang names for all languages
# - influenced and influenced_by only allow language names in github
# - paradigms only allow all entries from raw_paradigms.json

require 'json'
require 'set'

MIN_OCCURENCE = 3
github_langs = JSON.parse(File.read(File.expand_path '../../github_lang.json', __FILE__))
lang = JSON.parse(File.read(File.expand_path '../../lang_pretty.json', __FILE__))
raw_paras = JSON.parse(File.read(File.expand_path '../../raw_paradigms.json', __FILE__))

count = []
lang.each do |l|
  next unless l['paradigms']
  pstr = l['paradigms'].join(', ')
  raw_paras.each_with_index do |p, i|
    count[i] ||= 0
    count[i] += 1 if pstr[p]
  end
end

filtered_paras = raw_paras.zip(count)
  .sort { |a, b| b[1] <=> a[1] }
  .select { |i| i[1] >= MIN_OCCURENCE }
  .map { |i| i[0] }

def find_elem_in_set(name, set,
                       comp = lambda {|elem, sample| elem.gsub(/\s*/, '').downcase == sample.gsub(/\s*/, '').downcase })
  set.each do |gl|
    return gl if comp.call(name, gl)
  end
  return nil
end

# select uniq languages posted on github
filtered_lang = Set.new
lang.each do |l|
  gl = find_elem_in_set(l['name'], github_langs.keys)
  if gl
    l['name'] = gl
    filtered_lang << l
  end
end
filtered_lang = filtered_lang.to_a

# clean influenced and influenced_by properties
filtered_lang_names = filtered_lang.map {|i| i['name']}
filtered_lang.each do |l|
  if l['influenced']
    l['influenced'].map! do |il|
      format_name = find_elem_in_set(il, filtered_lang_names)
      format_name ? format_name : nil
    end.compact!
  end

  if l['influenced_by']
    l['influenced_by'].map! do |il|
      format_name = find_elem_in_set(il, filtered_lang_names)
      format_name ? format_name : nil
    end.compact!
  end

  if l['paradigms']
    l['paradigms'].map! do |p|
      format_para = find_elem_in_set(p, filtered_paras, lambda {|elem, sample| elem[sample]})
      format_para ? format_para : nil
    end.compact!
  end
end

lang_hash = {}
filtered_lang.each { |l| lang_hash[l['name']] = l }

# build missing bi-relationship between influenced and influence_by
filtered_lang.each do |l|
  l_name = l['name']
  (l['influenced'] || []).each do |il_name|
    il = lang_hash[il_name]
    il['influenced_by'] ||= []
    il['influenced_by'] << l_name unless il['influenced_by'].include?(l_name)
  end

  (l['influenced_by'] || []).each do |il_name|
    il = lang_hash[il_name]
    il['influenced'] ||= []
    il['influenced'] << l_name unless il['influenced'].include?(l_name)
  end
end

# remove self-reference
filtered_lang.each do |l|
  l_name = l['name']
  l['influenced_by'].delete(l_name) if (l['influenced_by'] || []).include?(l_name)
  l['influenced'].delete(l_name) if (l['influenced'] || []).include?(l_name)
end

output = File.new(File.expand_path("../../lang.json", __FILE__), 'w')
output.write(JSON.pretty_generate(filtered_lang))
output.close
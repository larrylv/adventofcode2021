#!/usr/bin/env ruby

require 'set'

lines = File.readlines(ARGV[0]).map(&:strip)

def instructions_and_pair_insertion_rules(lines)
  instructions = lines[0].split("")

  rules = {}
  (1...lines.size).each do |idx|
    line = lines[idx]
    next if line == ""

    k, v = line.split(" -> ")
    rules[k] = v
  end

  [instructions, rules]
end

instructions, rules = instructions_and_pair_insertion_rules(lines)

pair_cnt = Hash.new(0)
element_cnt = Hash.new(0)
instructions.each {|element| element_cnt[element] += 1}
instructions.each_cons(2) { |element_a, element_b| pair_cnt[element_a + element_b] += 1 }

40.times do
  new_pair_cnt = Hash.new(0)
  pair_cnt.each do |pair, v|
    element_cnt[rules[pair]] += v
    new_pair_cnt[pair[0] + rules[pair]] += v
    new_pair_cnt[rules[pair] + pair[1]] += v
  end

  pair_cnt = new_pair_cnt.dup
end

p pair_cnt
p element_cnt
sorted_cnt = element_cnt.values.sort
p sorted_cnt
p sorted_cnt[-1] - sorted_cnt[0]

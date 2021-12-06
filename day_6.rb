#!/usr/bin/env ruby

lines = File.readlines(ARGV[0]).map(&:strip)
states = lines[0].split(",").map(&:to_i)
mem = Hash.new {|h, k| h[k] = Hash.new {|h2, k2| h2[k2] = -1}}

def incremental_fish_count(mem, n, days)
  return 1 if n >= days
  return mem[n][days] if mem[n][days] != -1

  mem[n][days] = incremental_fish_count(mem, 6, days - n - 1) + incremental_fish_count(mem, 8, days - n - 1)
end

puts states.sum {|state| incremental_fish_count(mem, state, 256)}

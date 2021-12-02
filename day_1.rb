#!/usr/bin/env ruby

# part one
puts File.open(ARGV[0]).each_cons(2).count { |a, b| a.to_i < b.to_i }

# part two
puts File.open(ARGV[0]).each_cons(4).count { |a, _, _, b| a.to_i < b.to_i }

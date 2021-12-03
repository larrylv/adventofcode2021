#!/usr/bin/env ruby

require 'set'

def get_gamma(lines)
  (0...lines[0].size).map do |idx|
    (lines.map {|line| line[idx]}.count{|c| c == "0"} > lines.size / 2) ? "0" : "1"
  end.join("")
end

def get_epsilon(gamma)
  (("1" * gamma.size).to_i(2) ^ gamma.to_i(2)).to_s(2).rjust(gamma.size, "0")
end

# part 1
lines = File.readlines(ARGV[0]).map(&:strip)
gamma = get_gamma(lines)
puts gamma.to_i(2) * get_epsilon(gamma).to_i(2)

# part 2
def get_rating_value(rating_type, lines)
  set = Set.new(lines)

  (0...lines[0].size).each do |idx|
    eligible_lines = set.to_a
    rating_value = get_gamma(eligible_lines)
    rating_value = get_epsilon(rating_value) if rating_type == "epsilon"

    eligible_lines.each do |line|
      set.delete(line) if line[idx] != rating_value[idx]
      return set.to_a.first.to_i(2) if set.size == 1
    end
  end
end

puts get_rating_value("oxgen", lines) * get_rating_value("epsilon", lines)

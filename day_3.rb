#!/usr/bin/env ruby

require 'set'

def get_gamma(lines)
  rotated_matrix = []

  (0...lines[0].size).each do |idx|
    rotated_matrix[idx] = []
    lines.each { |line| rotated_matrix[idx] << line[idx] }
  end

  (0...lines[0].size).inject("") do |gamma, idx|
    if rotated_matrix[idx].count {|c| c == "0"} > lines.size / 2
      gamma << "0"
    else
      gamma << "1"
    end
    gamma
  end
end

def get_epsilon(gamma)
  xor_str = "1" * gamma.size

  (xor_str.to_i(2) ^ gamma.to_i(2)).to_s(2).rjust(gamma.size, "0")
end

# part 1
lines = File.readlines(ARGV[0]).map(&:strip)
gamma = get_gamma(lines)
puts gamma.to_i(2) * get_epsilon(gamma).to_i(2)

# part 2
def get_rating_value(rating_type, lines)
  set = Set.new
  lines.each { |line| set.add(line) }
  str_size = lines[0].size

  (0...str_size).each do |idx|
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

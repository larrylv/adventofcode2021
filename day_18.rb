#!/usr/bin/env ruby

require 'pqueue'
require 'set'

MAX_NUMBER = 1 << 64

lines = File.readlines(ARGV[0]).map(&:strip)

def explode(pair, snailfish, left_bracket_idx, right_bracket_idx)
  lhs = snailfish[0...left_bracket_idx]
  rhs = snailfish[right_bracket_idx+1..-1]

  lhs_cur = lhs.size - 1
  left_regular_number_start_idx = -1
  left_regular_number_end_idx = -1
  # if pair[0] == 8 && pair[1] == 1
  #   require 'pry'; binding.pry
  # end
  while lhs_cur >= 0
    if ["]", ",", "["].include? lhs[lhs_cur]
      if left_regular_number_end_idx != -1
        left_regular_number_start_idx = lhs_cur + 1
        break
      end
    else
      if left_regular_number_end_idx == -1
        left_regular_number_end_idx = lhs_cur
      end
    end

    lhs_cur -= 1
  end
  if left_regular_number_start_idx != -1
    lhs[left_regular_number_start_idx..left_regular_number_end_idx] = (lhs[left_regular_number_start_idx..left_regular_number_end_idx].to_i + pair[0]).to_s
  end


  rhs_cur = 0
  right_regular_number_start_idx = -1
  right_regular_number_end_idx = -1
  while rhs_cur < rhs.size
    if ["]", ",", "["].include? rhs[rhs_cur]
      if right_regular_number_start_idx != -1
        right_regular_number_end_idx = rhs_cur - 1
        break
      end
    else
      if right_regular_number_start_idx == -1
        right_regular_number_start_idx = rhs_cur
      end
    end

    rhs_cur += 1
  end

  if right_regular_number_start_idx != -1
    rhs[right_regular_number_start_idx..right_regular_number_end_idx] = (rhs[right_regular_number_start_idx..right_regular_number_end_idx].to_i + pair[1]).to_s
  end

  # p "after explode: #{lhs + "0" + rhs}"
  lhs + "0" + rhs
end

def split(number, snailfish, number_start_idx, number_end_idx)
  snailfish[number_start_idx..number_end_idx] = "[#{number/2},#{number-number/2}]"
  # p "after split: #{snailfish}"
  snailfish
end

def reduce_snailfish(snailfish)
  current_number = ""
  nested_level = 0
  current_pair = []
  last_bracket_idx = 0

  # explode
  snailfish.chars.each_with_index do |c, idx|
    if c == "["
      last_bracket_idx = idx
      nested_level += 1
      current_pair = []
    elsif c == "]"
      current_pair << current_number.to_i
      current_number = ""
      if nested_level > 4
        # p "explode: #{snailfish[0..idx]}"
        return reduce_snailfish(explode(current_pair, snailfish, last_bracket_idx, idx))
      end
      current_pair = []
      nested_level -= 1
    elsif c == ","
      current_pair << current_number.to_i
      current_number = ""
    else
      current_number += c
    end
  end

  # split
  current_number = ""
  number_start_idx = -1
  snailfish.chars.each_with_index do |c, idx|
    if ["]", ",", "["].include? c
      if current_number != "" && current_number.to_i >= 10
        return reduce_snailfish(split(current_number.to_i, snailfish, number_start_idx, idx - 1))
      end
      number_start_idx = -1
      current_number = ""
    else
      current_number += c
      if number_start_idx == -1
        number_start_idx = idx
      end
    end
  end

  snailfish
end

def add_snailfish(snailfish_a, snailfish_b)
  "[#{snailfish_a},#{snailfish_b}]"
end

def convert_to_array(snailfish)
  return snailfish.to_i if snailfish[0] != "["

  left_bracket_number = 0
  (1...snailfish.size-1).each do |idx|
    if snailfish[idx] == "," && left_bracket_number == 0
      return [convert_to_array(snailfish[1...idx]), convert_to_array(snailfish[idx+1..-1])]
    elsif snailfish[idx] == "["
      left_bracket_number += 1
    elsif snailfish[idx] == "]"
      left_bracket_number -= 1
    end
  end
end

def mag(snailfish)
  return snailfish if !snailfish.is_a?(Array)

  3 * mag(snailfish[0]) + 2 * mag(snailfish[1])
end

snailfish = lines[0]
(1...lines.size).each do |idx|
  # p "line: #{idx-1} + #{idx}"
  snailfish = reduce_snailfish(add_snailfish(snailfish, lines[idx]))
  # p snailfish
end

# part 1
p mag(convert_to_array(snailfish))

# part 2
max_mag = 0
lines.each_with_index do |line_a, i|
  lines.each_with_index do |line_b, j|
    next if i == j

    max_mag = [max_mag, mag(convert_to_array(reduce_snailfish(add_snailfish(line_a, line_b))))].max
  end
end

p max_mag

#!/usr/bin/env ruby

lines = File.readlines(ARGV[0]).map do |line|
  line.strip.split("|").map{|x| x.split(" ")}
end

all_letters = ("a".."g").to_a

segment_display_map = {
  "abcefg" => 0,
  "cf" => 1,
  "acdeg" => 2,
  "acdfg" => 3,
  "bcdf" => 4,
  "abdfg" => 5,
  "abdefg" => 6,
  "acf" => 7,
  "abcdefg" => 8,
  "abcdfg" => 9
}

def is_valid_wire_map?(wire_map, unique_signal_patterns, segment_display_map)
  unique_signal_patterns.all? do |pattern|
    !segment_display_map[pattern.chars.uniq.sort.map {|c| wire_map[c]}.sort.join("")].nil?
  end
end

def build_wire_map(unique_signal_patterns, segment_display_map, all_letters)
  all_letters.permutation.each do |permutation|
    wire_map = permutation.map.with_index { |letter, idx| [letter, all_letters[idx]] }.to_h

    if is_valid_wire_map?(wire_map, unique_signal_patterns, segment_display_map)
      return wire_map
    end
  end
end

values = lines.map do |unique_signal_patterns, output_values|
  wire_map = build_wire_map(unique_signal_patterns, segment_display_map, all_letters)

  output_values.map do |value|
    segment_display_map[value.chars.uniq.map {|c| wire_map[c]}.sort.join("")].to_s
  end.join("").to_i
end

p values.sum

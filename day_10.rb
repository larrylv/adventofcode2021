#!/usr/bin/env ruby

lines = File.readlines(ARGV[0]).map(&:strip)

chunks = {
  "(" => ")",
  "[" => "]",
  "{" => "}",
  "<" => ">",
}

pointsMap = {
  ")" => 1,
  "]" => 2,
  "}" => 3,
  ">" => 4,
}

points = []
lines.each do |line|
  point = 0
  nav = []
  corrupted = false
  line.chars.each do |char|
    if chunks[char]
      nav << char
    else
      if nav.size == 0
        corrupted = true
        break
      elsif chunks[nav[-1]] != char
        corrupted = true
        break
      else
        nav.pop
      end
    end
  end
  next if corrupted

  nav.reverse.each do |char|
    point *= 5
    point += pointsMap[chunks[char]]
  end

  points << point
end

p points.sort[points.size/2]

#!/usr/bin/env ruby

def mark_map(map, x1, y1, x2, y2)
  x_min, x_max = [x1, x2].min, [x1, x2].max
  y_min, y_max = [y1, y2].min, [y1, y2].max
  if x1 == x2
    (y_min..y_max).each { |y| map[x1][y] += 1 }
  elsif y1 == y2
    (x_min..x_max).each { |x| map[x][y1] += 1 }
  else # part 2
    if (x1 < x2 && y1 < y2) || (x1 > x2 && y1 > y2)
      (x_min..x_max).each_with_index { |x, idx| map[x][y_min+idx] += 1 }
    else
      (x_min..x_max).each_with_index { |x, idx| map[x][y_max-idx] += 1 }
    end
  end
end

lines = File.readlines(ARGV[0]).map(&:strip)
map = Hash.new {|h, k| h[k] = Hash.new {|h2, k2| h2[k2] = 0}}
lines.each do |line|
  x1_y1, x2_y2 = line.split(" -> ")
  x1, y1 = x1_y1.split(",").map(&:to_i)
  x2, y2 = x2_y2.split(",").map(&:to_i)
  mark_map(map, x1, y1, x2, y2)
end

points = 0
map.each do |x, y_map|
  y_map.each do |y, line_cnt|
    points += 1 if line_cnt >= 2
  end
end

puts points

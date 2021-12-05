#!/usr/bin/env ruby

def mark_map(map, x1, y1, x2, y2)
  if x1 == x2
    y_min = [y1, y2].min
    y_max = [y1, y2].max
    (y_min..y_max).each do |y|
      map[x1][y] ||= 0
      map[x1][y] += 1
    end
  elsif y1 == y2
    x_min = [x1, x2].min
    x_max = [x1, x2].max
    (x_min..x_max).each do |x|
      map[x][y1] ||= 0
      map[x][y1] += 1
    end
  else # part 2
    x_min = [x1, x2].min
    x_max = [x1, x2].max
    if (x1 < x2 && y1 < y2) || (x1 > x2 && y1 > y2)
      (x_min..x_max).each do |x|
        map[x][[y1, y2].min+(x-x_min)] ||= 0
        map[x][[y1, y2].min+(x-x_min)] += 1
      end
    else
      (x_min..x_max).each do |x|
        map[x][[y1, y2].max-(x-x_min)] ||= 0
        map[x][[y1, y2].max-(x-x_min)] += 1
      end
    end
  end
end

lines = File.readlines(ARGV[0]).map(&:strip)
map = Hash.new {|h, k| h[k] = {}}
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

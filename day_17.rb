#!/usr/bin/env ruby

require 'pqueue'
require 'set'

MAX_NUMBER = 1 << 64

line = File.readlines(ARGV[0]).map(&:strip).first

x_values, y_values = line["target area: ".size..-1].split(", ")
x_min, x_max = x_values["x=".size..-1].split("..").map(&:to_i)
y_min, y_max = y_values["y=".size..-1].split("..").map(&:to_i)

def launch_probe(current_x, current_y, target_x_min, target_x_max, target_y_min, target_y_max)
  within_target_area = false
  x_velocity = current_x
  y_velocity = current_y
  current_y_max = current_y

  while true
    current_y_max = current_y if current_y > current_y_max

    if current_x >= target_x_min && current_x <= target_x_max && current_y >= target_y_min && current_y <= target_y_max
      within_target_area = true
      break
    end

    if x_velocity > 0
      x_velocity -= 1
    elsif x_velocity < 0
      x_velocity += 1
    end
    y_velocity -= 1
    current_x += x_velocity
    current_y += y_velocity

    if current_y < target_y_min
      break
    end

    # p [current_x, current_y]
  end

  return current_y_max if within_target_area
end

# part one
#
# Eventually, x is gonna stop moving and it happens to fall into the target area x range.
# then eventually y will reach to its highest position when y velocity reaches 0, which
# would be `initial_y_velocity * (initial_y_velocity + 1) / 2`.
# and then it will start falling, and when the y position reaches to 0, the y_velocity is
# gonna be `-initial_y_velocity`.
# So if we want y to be in the target range, `-initial_y_velocity - 1` (the next y position)
# needs to be >= y_min.
# So to maximize the highest position, `initial_y_velocity` needs to be equal to `abs(y_min) - 1`.
# So the highest position would be:
# `(abs(y_min) - 1) * (abs(y_min) - 1 + 1) / 2`
#
p y_min.abs * (y_min.abs - 1) / 2

# part two

# min x velocity can't be negative since the target area is a positive range
#
# x will stop moving once velocity is 0, and when that happens,
# x position will be `(x_velocity + 1) * x_velocity / 2`.
# So `x_velocity` has to be big enough so that the above value could fall into
# the target area (>= target_x_min).
def find_min_x_velocity(target_x_min)
  i = 0
  while true
    return i if i * (i+1) / 2 >= target_x_min

    i += 1
  end
end

result = []
(find_min_x_velocity(x_min)..x_max).each do |current_x|
  # higher bound for y is `y_min.abs - 1`. see explanation for part one.
  (y_min..y_min.abs-1).each do |current_y|
    # p [current_x, current_y]
    current_y_max = launch_probe(current_x, current_y, x_min, x_max, y_min, y_max)
    result << current_y_max if current_y_max
  end
end

p result.count

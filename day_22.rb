#!/usr/bin/env ruby

require 'pqueue'
require 'set'

MAX_NUMBER = 1 << 64

lines = File.readlines(ARGV[0]).map(&:strip)

def execute_part_one(line, cubes)
  on_off, xyz = line.split(" ")
  on = on_off == "on"

  x, y, z = xyz.split(",")
  x_min, x_max = x.split("x=").last.split("..").map(&:to_i)
  y_min, y_max = y.split("y=").last.split("..").map(&:to_i)
  z_min, z_max = z.split("z=").last.split("..").map(&:to_i)

  max = [x_min.abs, x_max.abs, y_min.abs, y_max.abs, z_min.abs, z_max.abs].max

  x_min = [x_min, -50].max
  x_max = [x_max, 50].min
  y_min = [y_min, -50].max
  y_max = [y_max, 50].min
  z_min = [z_min, -50].max
  z_max = [z_max, 50].min

  (x_min..x_max).each do |x|
    (y_min..y_max).each do |y|
      (z_min..z_max).each do |z|
        cubes[x][y][z] = on
      end
    end
  end

  max
end

# part one
cubes = Hash.new {|h, k| h[k] = Hash.new{|h2, k2| h2[k2] = Hash.new{|h3, k3| h3[k3] = false}}}
max_number = -1
lines.each do |line|
  max_number = [execute_part_one(line, cubes), max_number].max
end
p "max_number: #{max_number}"

cnt = 0
(-50..50).each do |x|
  (-50..50).each do |y|
    (-50..50).each do |z|
      if cubes[x][y][z] == true
        cnt += 1
      end
    end
  end
end

p cnt

# part two

def set_range_on(node, on, x_range, y_range, z_range)
  x_common = x_range & node.x_range
  y_common = y_range & node.y_range
  z_common = z_range & node.z_range

  # no overlapping
  if x_common.nil? || y_common.nil? || z_common.nil?
    return
  end

  if node.left_node.nil? && node.right_node.nil? # leaf
    # no need to update
    return if node.on == on

    # split x
    if x_common != node.x_range
      left_x_range = (node.x_range.min..x_common.min-1)
      if left_x_range.count == 0
        left_x_range = x_common
        right_x_range = (x_common.max+1..node.x_range.max)
        left_on_value = on
        right_on_value = node.on
      else
        right_x_range = (x_common.min..node.x_range.max)
        left_on_value = node.on
        right_on_value = on
      end
      node.left_node = Node.new(
        x_range: left_x_range,
        y_range: node.y_range,
        z_range: node.z_range,
        on: node.on,
      )
      node.right_node = Node.new(
        x_range: right_x_range,
        y_range: node.y_range,
        z_range: node.z_range,
        on: node.on,
      )
      set_range_on(node.left_node, left_on_value, x_common, y_common, z_common)
      set_range_on(node.right_node, right_on_value, x_common, y_common, z_common)
      return
    end

    # split y
    if y_common != node.y_range
      left_y_range = (node.y_range.min..y_common.min-1)
      if left_y_range.count == 0
        left_y_range = y_common
        right_y_range = (y_common.max+1..node.y_range.max)
        left_on_value = on
        right_on_value = node.on
      else
        right_y_range = (y_common.min..node.y_range.max)
        left_on_value = node.on
        right_on_value = on
      end
      node.left_node = Node.new(
        x_range: node.x_range,
        y_range: left_y_range,
        z_range: node.z_range,
        on: node.on,
      )
      node.right_node = Node.new(
        x_range: node.x_range,
        y_range: right_y_range,
        z_range: node.z_range,
        on: node.on,
      )
      set_range_on(node.left_node, left_on_value, x_common, y_common, z_common)
      set_range_on(node.right_node, right_on_value, x_common, y_common, z_common)
      return
    end

    # split z
    if z_common != node.z_range
      left_z_range = (node.z_range.min..z_common.min-1)
      if left_z_range.count == 0
        left_z_range = z_common
        right_z_range = (z_common.max+1..node.z_range.max)
        left_on_value = on
        right_on_value = node.on
      else
        right_z_range = (z_common.min..node.z_range.max)
        left_on_value = node.on
        right_on_value = on
      end
      node.left_node = Node.new(
        x_range: node.x_range,
        y_range: node.y_range,
        z_range: left_z_range,
        on: node.on,
      )
      node.right_node = Node.new(
        x_range: node.x_range,
        y_range: node.y_range,
        z_range: right_z_range,
        on: node.on,
      )
      set_range_on(node.left_node, left_on_value, x_common, y_common, z_common)
      set_range_on(node.right_node, right_on_value, x_common, y_common, z_common)
      return
    end

    node.left_node = nil
    node.right_node = nil
    node.on = on
  else
    set_range_on(node.left_node, on, x_common, y_common, z_common)
    set_range_on(node.right_node, on, x_common, y_common, z_common)
  end
end

def execute_part_two(line, node)
  on_off, xyz = line.split(" ")
  on = on_off == "on"

  x, y, z = xyz.split(",")
  x_min, x_max = x.split("x=").last.split("..").map(&:to_i)
  y_min, y_max = y.split("y=").last.split("..").map(&:to_i)
  z_min, z_max = z.split("z=").last.split("..").map(&:to_i)

  set_range_on(node, on, (x_min..x_max), (y_min..y_max), (z_min..z_max))
end

class Node
  attr_accessor :left_node # Node or nil
  attr_accessor :right_node # Node or nil

  attr_accessor :x_range # range
  attr_accessor :y_range # range
  attr_accessor :z_range # range
  attr_accessor :on # bool

  def initialize(params = {})
    params.each do |key, value|
      setter = "#{key}="
      send(setter, value) if respond_to?(setter.to_sym, false)
    end
  end
end

class Range
  def intersection(other)
    return nil if (self.max < other.min || self.min > other.max)

    return [self.min, other.min].max..[self.max, other.max].min
  end

  alias_method :&, :intersection
end

MAX_COORDINATE = 1000000
root_node = Node.new(
  x_range: (-MAX_COORDINATE..MAX_COORDINATE),
  y_range: (-MAX_COORDINATE..MAX_COORDINATE),
  z_range: (-MAX_COORDINATE..MAX_COORDINATE),
  on: false,
)

lines.each do |line|
  execute_part_two(line, root_node)
end

def count_on_node(node)
  if node.left_node.nil? && node.right_node.nil?
    if node.on == true
      return node.x_range.count * node.y_range.count * node.z_range.count
    else
      return 0
    end
  end

  count_on_node(node.left_node) + count_on_node(node.right_node)
end

p count_on_node(root_node)

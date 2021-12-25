#!/usr/bin/env ruby

require 'pqueue'
require 'set'

MAX_NUMBER = 1 << 64

map = File.readlines(ARGV[0]).map(&:strip).map {|line| line.split("")}

def one_step(map)
  row_cnt = map.size
  column_cnt = map[0].size

  new_map = map.map do |line|
    line.map {|cucumber| cucumber}
  end

  # east
  map.each_with_index do |line, row|
    line.each_with_index do |cucumber, column|
      next if cucumber != ">"

      next if map[row][(column + 1) % column_cnt] != "."

      new_map[row][column] = "."
      new_map[row][(column + 1) % column_cnt] = ">"
    end
  end

  map = new_map.map do |line|
    line.map {|cucumber| cucumber}
  end

  # south
  map.each_with_index do |line, row|
    line.each_with_index do |cucumber, column|
      next if cucumber != "v"

      next if map[(row + 1) % row_cnt][column] != "."

      new_map[row][column] = "."
      new_map[(row + 1) % row_cnt][column] = "v"
    end
  end

  new_map
end

def print_map(m)
  m.each do |line|
    p line.join("")
  end
end

# part one

step = 0
while true
  step += 1
  new_map = one_step(map)
  if new_map == map
    print_map(new_map)
    break
  end
  map = new_map.map do |line|
    line.map {|cucumber| cucumber}
  end
end

p step

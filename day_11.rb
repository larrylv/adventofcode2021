#!/usr/bin/env ruby

matrix = File.readlines(ARGV[0]).map(&:strip).map {|line| line.split("").map(&:to_i)}

def transition(matrix, map, should_increase)
  flashes = 0

  (0...10).each do |i|
    (0...10).each do |j|
      matrix[i][j] += 1 if should_increase
      if matrix[i][j] >= 10
        flashes += 1

        map[i][j] = true
        matrix[i][j] -= 10
        matrix[i-1][j-1] += 1 if i >= 1 && j >= 1 && !map[i-1][j-1]
        matrix[i-1][j+1] += 1 if i >= 1 && j < 9 && !map[i-1][j+1]
        matrix[i+1][j-1] += 1 if i < 9 && j >= 1 && !map[i+1][j-1]
        matrix[i+1][j+1] += 1 if i < 9 && j < 9 && !map[i+1][j+1]
        matrix[i-1][j] += 1 if i >= 1 && !map[i-1][j]
        matrix[i+1][j] += 1 if i < 9 && !map[i+1][j]
        matrix[i][j-1] += 1 if j >=1 && !map[i][j-1]
        matrix[i][j+1] += 1 if j < 9 && !map[i][j+1]
      end
    end
  end

  (0...10).each do |i|
    (0...10).each do |j|
      if matrix[i][j] >= 10
        return transition(matrix, map, false) + flashes
      end
    end
  end

  map.each { |i, h2| h2.each { |j, v| matrix[i][j] = 0 if v } }

  flashes
end

# part 1
flashes = (0...100).map do |_|
  map = Hash.new {|h, k| h[k] = Hash.new{|h2, k2| h2[k2] = false}}
  transition(matrix, map, true)
end

p flashes.sum

# part 2
cnt = 100
while true
  cnt += 1
  map = Hash.new {|h, k| h[k] = Hash.new{|h2, k2| h2[k2] = false}}
  if transition(matrix, map, true) == 100
    p cnt
    break
  end
end


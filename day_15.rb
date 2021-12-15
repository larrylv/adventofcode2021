#!/usr/bin/env ruby

require 'pqueue'

MAX_NUMBER = 1 << 64

matrix = File.readlines(ARGV[0]).map(&:strip).map {|line| line.split("").map(&:to_i)}

def lowest_risk(matrix)
  row = matrix.count
  column = matrix[0].count
  dp = Hash.new{|h, k| h[k] = Hash.new{|h2, k2| h2[k2] = MAX_NUMBER}}

  dp[0][0] = 0
  (0...row).each do |i|
    (0...column).each do |j|
      if i >= 1
        dp[i][j] = dp[i-1][j] + matrix[i][j]
      end

      if j >= 1
        dp[i][j] = [dp[i][j-1] + matrix[i][j], dp[i][j]].min
      end
    end
  end

  dp[row-1][column-1]
end

# part one
p lowest_risk(matrix)

def build_new_matrix(matrix)
  row = matrix.count
  column = matrix[0].count

  offsets = (0...5).map do |i|
    (0...5).map do |j|
      [i * row, j * column]
    end
  end

  new_matrix = []
  (0...row).each do |i|
    (0...column).each do |j|
      offsets.each_with_index do |offset_for_a_row, idx_a|
        initial_value = matrix[i][j] + idx_a
        initial_value -= 9 if initial_value >= 10

        offset_for_a_row.each do |ij_offset|
          new_matrix[i + ij_offset[0]] ||= []
          new_matrix[i + ij_offset[0]][j + ij_offset[1]] = initial_value
          initial_value += 1
          initial_value -= 9 if initial_value >= 10
        end
      end
    end
  end

  new_matrix
end

# part two
new_matrix = build_new_matrix(matrix)

# wrong answer!
# you can go left / up too!!!
# p lowest_risk(new_matrix)

def lowest_risk_with_dijkstra(matrix)
  row = matrix.count
  column = matrix[0].count

  visisted = Hash.new{|h, k| h[k] = Hash.new{|h2, k2| h2[k2] = false}}
  dist = Hash.new{|h, k| h[k] = Hash.new{|h2, k2| h2[k2] = MAX_NUMBER}}
  pq = PQueue.new{|x, y| dist[x[0]][x[1]] < dist[y[0]][y[1]]}

  pq.push([0, 0])
  dist[0][0] = 0
  directions = [
    [-1, 0],
    [1, 0],
    [0, -1],
    [0, 1],
  ]

  while pq.size != 0
    ij = pq.pop
    i, j = ij[0], ij[1]
    visisted[i][j] = true

    directions.each do |i_offset, j_offset|
      new_i, new_j = i + i_offset, j + j_offset
      if new_i >= 0 && new_i < row && new_j >= 0 && new_j < column
        if !visisted[new_i][new_j] && dist[i][j] + matrix[new_i][new_j] < dist[new_i][new_j]
          dist[new_i][new_j] = dist[i][j] + matrix[new_i][new_j]
          pq.push([new_i, new_j])
        end
      end
    end
  end

  dist[row-1][column-1]
end

p lowest_risk_with_dijkstra(new_matrix)


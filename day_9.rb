#!/usr/bin/env ruby

lines = File.readlines(ARGV[0]).map(&:strip)
matrix = lines.map { |line| line.split("").map(&:to_i) }

def find_low_points(matrix)
  low_points = []
  matrix.each_with_index do |row, i|
    row.each_with_index do |height, j|
      left = j >= 1 ? row[j-1] : 10
      right = j < row.count - 1 ? row[j+1] : 10
      up = i >= 1 ? matrix[i-1][j] : 10
      down = i < matrix.count - 1 ? matrix[i+1][j] : 10
      if height < left && height < right && height < up && height < down
        low_points << [i, j]
      end
    end
  end

  low_points
end

def get_basin_size(matrix, i, j, basin_mem, mark_map)
  return 0 if mark_map[i][j]
  return basin_mem[i][j] if basin_mem[i][j] > 0

  mark_map[i][j] = true

  row = matrix[i]
  left = j >= 1 ? row[j-1] : 10
  right = j < row.count - 1 ? row[j+1] : 10
  up = i >= 1 ? matrix[i-1][j] : 10
  down = i < matrix.count - 1 ? matrix[i+1][j] : 10
  height = matrix[i][j]

  left_basin = get_basin_size(matrix, i, j - 1, basin_mem, mark_map) if j >= 1 && height < left && left != 9
  right_basin = get_basin_size(matrix, i, j + 1, basin_mem, mark_map) if j < row.count - 1 && height < right && right != 9
  up_basin = get_basin_size(matrix, i - 1, j, basin_mem, mark_map) if i >= 1 && height < up && up != 9
  down_basin = get_basin_size(matrix, i + 1, j, basin_mem, mark_map) if i < matrix.count - 1 && height < down && down != 9

  basin_mem[i][j] = (left_basin || 0) + (right_basin || 0) + (up_basin || 0) + (down_basin || 0) + 1
end

low_points = find_low_points(matrix)
basin_mem = Hash.new {|h, k| h[k] = Hash.new {|h2, k2| h2[k2] = 0}}
basins = low_points.map do |i, j|
  mark_map = Hash.new {|h, k| h[k] = Hash.new {|h2, k2| h2[k2] = false}}
  get_basin_size(matrix, i, j, basin_mem, mark_map)
end

p basins.sort.reverse.take(3).inject(1) {|v, basin| v * basin}

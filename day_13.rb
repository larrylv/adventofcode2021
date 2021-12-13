#!/usr/bin/env ruby

require 'set'

lines = File.readlines(ARGV[0]).map(&:strip)

def draw_paper(lines)
  paper = Hash.new {|h, k| h[k] = Hash.new {|h2, k2| h2[k2] = "."}}
  max_x = 0
  max_y = 0
  instructions = []

  lines.each do |line|
    next if line == ""
    if line.start_with?("fold along")
      instructions << line.split(" ").last
      next
    end

    y, x = line.split(",").map(&:to_i)
    paper[x][y] = "#"

    max_x = [x, max_x].max
    max_y = [y, max_y].max

  end

  [paper, max_x, max_y, instructions]
end

def fold_up(paper, row, column, line_number)
  new_paper = Hash.new {|h, k| h[k] = Hash.new {|h2, k2| h2[k2] = "."}}

  if line_number >= row / 2
    new_row = line_number - 1
  else
    new_row = row - line_number - 1
  end
  new_row_copy = new_row

  idx = 1
  while new_row >= 0
    (0..column).each do |y|
      if line_number - idx >= 0 && paper[line_number - idx][y] == "#"
        new_paper[new_row][y] = "#"
      end
      if line_number + idx <= row && paper[line_number + idx][y] == "#"
        new_paper[new_row][y] = "#"
      end
    end
    new_row -= 1
    idx += 1
  end

  [new_paper, new_row_copy, column]
end

def fold_left(paper, row, column, column_number)
  new_paper = Hash.new {|h, k| h[k] = Hash.new {|h2, k2| h2[k2] = "."}}

  if column_number >= column / 2
    new_column = column_number - 1
  else
    new_column = column - column_number - 1
  end
  new_column_copy = new_column

  idx = 1
  while new_column >= 0
    (0..row).each do |x|
      if column_number - idx >= 0 && paper[x][column_number - idx] == "#"
        new_paper[x][new_column] = "#"
      end
      if column_number + idx <= column && paper[x][column_number + idx] == "#"
        new_paper[x][new_column] = "#"
      end
    end
    new_column -= 1
    idx += 1
  end

  [new_paper, row, new_column_copy]
end

def fold(paper, row, column, instruction)
  if instruction.start_with?("x=")
    fold_left(paper, row, column, instruction.split("=").last.to_i)
  else
    fold_up(paper, row, column, instruction.split("=").last.to_i)
  end
end


paper, row, column, instructions = draw_paper(lines)

# part 0
# paper, row, column = fold(paper, row, column, instructions[0])

# p paper.values.map{|h| h.values}.flatten.count

# part 1
instructions.each do |instruction|
  paper, row, column = fold(paper, row, column, instruction)
end

(0..row).each do |x|
  line = (0..column).map do |y|
    paper[x][y]
  end.join("")
  puts line
end

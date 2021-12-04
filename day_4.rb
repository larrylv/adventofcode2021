#!/usr/bin/env ruby

require 'set'

def build_boards_bingo_sets(boards)
  m = Hash.new {|h, k| h[k] = []}
  boards.each_with_index do |board, idx|
    (0...5).each do |j|
      m[idx] << Set.new(board[j])
      m[idx] << Set.new((0...5).map{|k| board[k][j]})
    end
  end
  m
end

lines = File.readlines(ARGV[0]).map(&:strip)

numbers = lines[0].split(",").map(&:to_i)
boards = []
board_idx = -1

(1...lines.size).each do |idx|
  line = lines[idx]
  if line == ""
    board_idx += 1
    next
  end

  (boards[board_idx] ||= []) << line.split(" ").map(&:to_i)
end

boards_map = build_boards_bingo_sets(boards)
current_set = Set.new
bingo_boards = {}
bingo_scores = []

numbers.each do |number|
  current_set.add(number)
  boards_map.each do |board_idx, bingo_sets|
    next if bingo_boards[board_idx]

    bingo_sets.each do |bingo_set|
      if (bingo_set & current_set).size == 5
        bingo_boards[board_idx] = true
        unmarked = 0
        (0...5).each do |i|
          (0...5).each do |j|
            if !current_set.include?(boards[board_idx][i][j])
              unmarked += boards[board_idx][i][j]
            end
          end
        end

        bingo_scores << unmarked * number
        bingo_boards[board_idx] = true
      end
    end

  end
end

# part 1
puts bingo_scores[0]

# part 2
puts bingo_scores[-1]

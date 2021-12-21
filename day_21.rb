#!/usr/bin/env ruby

require 'pqueue'
require 'set'

MAX_NUMBER = 1 << 64

# lines = File.readlines(ARGV[0]).map(&:strip)

def cal_score(score)
  while score > 10
    score -= 10
  end

  score
end

# part 1

# player_1_position = 4
# player_2_position = 8
player_1_position = 6
player_2_position = 9

player_1_score = 0
player_2_score = 0
dice = 0
while true
  player_1_position = cal_score(player_1_position + dice * 3 + 6)
  player_1_score += player_1_position
  dice += 3
  if player_1_score >= 1000
    p player_2_score * dice
    break
  end

  player_2_position = cal_score(player_2_position + dice * 3 + 6)
  player_2_score += player_2_position
  dice += 3
  if player_2_score >= 1000
    p player_1_score * dice
    break
  end
end

# part two

def total_win(player_1_position, player_2_position, player_1_score, player_2_score, memo)
  if player_1_score >= 21
    return [1, 0]
  elsif player_2_score >= 21
    return [0, 1]
  elsif (v = memo[player_1_position][player_2_position][player_1_score][player_2_score]) != nil
    return v
  end

  player_1_win = 0
  player_2_win = 0
  [1, 2, 3].product([1, 2, 3], [1, 2, 3]).each do |i, j, k|
    player_2_win_additional, player_1_win_additional = total_win(
      player_2_position,
      cal_score(player_1_position + i + j + k),
      player_2_score,
      cal_score(player_1_position + i + j + k) + player_1_score,
      memo
    )
    player_1_win += player_1_win_additional
    player_2_win += player_2_win_additional
  end

  memo[player_1_position][player_2_position][player_1_score][player_2_score] = [player_1_win, player_2_win]
end

memo = Hash.new do |h, k|
  h[k] = Hash.new do |h2, k2|
    h2[k2] = Hash.new do |h3, k3|
      h3[k3] = Hash.new do |h4, k4|
        h4[k4] = nil
      end
    end
  end
end

# p total_win(4, 8, 0, 0, memo)
p total_win(6, 9, 0, 0, memo)

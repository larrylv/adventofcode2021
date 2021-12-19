#!/usr/bin/env ruby

require 'pqueue'
require 'set'

MAX_NUMBER = 1 << 64

scanners = File.readlines(ARGV[0]).join("").split("\n\n").map do |scanner|
  scanner.split("\n")[1..-1].map do |positions|
    positions.split(",").map(&:to_i)
  end
end

def beacons_in_different_orientations(beacon)
  result = []
  (0..2).to_a.permutation.each do |idx_x, idx_y, idx_z|
    [1, -1].product([1, -1], [1,-1]).each do |sign_x, sign_y, sign_z|
      result << [beacon[idx_x] * sign_x, beacon[idx_y] * sign_y, beacon[idx_z] * sign_z]
    end
  end
  result
end

def all_beacons_in_unpaired_scanner(scanners, unpaired_scanner, memo)
  return memo[unpaired_scanner] if memo[unpaired_scanner]

  all_beacons = scanners[unpaired_scanner].map {|beacon| beacons_in_different_orientations(beacon)}
  memo[unpaired_scanner] = all_beacons[0].zip(*all_beacons[1..-1])
end

# p beacons_in_different_orientations(scanners[0][0]).size

def pairing(scanners, paired_scanner, unpaired_scanner, unpaired_scanner_beacons_memo, paired_scanner_beacons_set_memo, scanner_positions)
  paired_scanner_beacons_set_memo[paired_scanner] ||= Set.new(scanners[paired_scanner])
  paired_scanner_beacons = paired_scanner_beacons_set_memo[paired_scanner]

  all_beacons_in_unpaired_scanner(scanners, unpaired_scanner, unpaired_scanner_beacons_memo).each do |unpaired_scanner_beacons|
    # p "unpaired_scanner_beacons: #{unpaired_scanner_beacons}"
    paired_scanner_beacons.each do |paired_scanner_beacon|
      unpaired_scanner_beacons.each do |unpaired_scanner_beacon|
      # p "base: #{unpaired_scanner_beacon}"
        offsets = (0..2).map {|idx| unpaired_scanner_beacon[idx] - paired_scanner_beacon[idx]}
        # p "offsets: #{offsets}"

        overlapping_cnt = unpaired_scanner_beacons.count do |beacon|
          # p "beacon: #{beacon}"
          paired_scanner_beacons.include?(
            (0..2).map {|idx| beacon[idx] - offsets[idx]}
          )
        end

        if overlapping_cnt >= 12
          p "found a pair: #{paired_scanner} #{unpaired_scanner}, overlapping_cnt: #{overlapping_cnt}, offsets: #{offsets}"
          scanners[unpaired_scanner] = unpaired_scanner_beacons.map do |beacon|
            (0..2).map {|idx| beacon[idx] - offsets[idx]}
          end
          scanner_positions << offsets
          return true
        end
      end
    end
  end

  false
end

paired_scanners = Set.new([0])
unpaired_scanners = Set.new((1...scanners.size))
tried_pairing = Hash.new {|h, k| h[k] = Hash.new{|h2, k2| h2[k2] = false}}
unpaired_scanner_beacons_memo = {}
paired_scanner_beacons_set_memo = {}
scanner_positions = []

while unpaired_scanners.size > 0
  p "unpaired_scanners.size: #{unpaired_scanners.size}"
  newly_paired = []
  unpaired_scanners.each do |unpaired_scanner|
    paired = false
    paired_scanners.each do |paired_scanner|
      next if tried_pairing[unpaired_scanner][paired_scanner]

      p "unpaired: #{unpaired_scanner}, paired: #{paired_scanner}"
      paired = pairing(scanners, paired_scanner, unpaired_scanner, unpaired_scanner_beacons_memo, paired_scanner_beacons_set_memo, scanner_positions)
      tried_pairing[unpaired_scanner][paired_scanner] = true
      if paired
        newly_paired << unpaired_scanner
        break
      end
    end
    paired_scanners.add(newly_paired.last) if paired
  end

  p "found newly paired: #{newly_paired}"
  newly_paired.each {|p| unpaired_scanners.delete(p)}
end

# part one

all_beacons = Set.new
scanners.each do |scanner|
  scanner.each do |beacon|
    all_beacons.add(beacon)
  end
end

p all_beacons.size

# require 'pry'; binding.pry

# part two

# my brute forcing for part one is very slow. I actually just used the offsets
# (scanner position) in the log and calculated the manhattan distances in pry.

max_distance = -1
scanner_positions.each do |scanner_a|
  scanner_positions.each do |scanner_b|
    distance = (0..2).sum {|idx| (scanner_a[idx] - scanner_b[idx]).abs}
    max_distance = [distance, max_distance].max
  end
end

p max_distance

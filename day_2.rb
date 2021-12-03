#!/usr/bin/env ruby

# part one
forward = 0
depth = 0
File.open(ARGV[0]).each do |line|
  command, units = line.strip.split(" ")
  units = units.to_i
  if command == "forward"
    forward += units
  elsif command == "down"
    depth += units
  elsif command == "up"
    depth -= units
  end
end

puts forward * depth

# part two

forward = 0
aim = 0
depth = 0
File.open(ARGV[0]).each do |line|
  command, units = line.strip.split(" ")
  units = units.to_i
  if command == "forward"
    forward += units
		depth += aim * units
  elsif command == "down"
		aim += units
  elsif command == "up"
		aim -= units
  end
end

puts forward * depth

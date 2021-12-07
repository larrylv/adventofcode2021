#!/usr/bin/env ruby

positions = File.readlines(ARGV[0]).map(&:strip).first.split(",").map(&:to_i).sort

fuelCost = Hash.new {|h, k| h[k] = 0}
(1..positions[-1]).each { |step| fuelCost[step] = fuelCost[step-1] + step }

minFuel = -1
(0..positions[-1]).each do |position_i|
  fuel = positions.sum { |position_j| fuelCost[(position_i-position_j).abs] }
  if minFuel == -1 || fuel < minFuel
    minFuel = fuel
  end
end

p minFuel

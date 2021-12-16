#!/usr/bin/env ruby

require 'pqueue'
require 'set'

MAX_NUMBER = 1 << 64

digits = File.readlines(ARGV[0]).map(&:strip).first.split("").map {|x| sprintf("%04d", Integer("0x#{x}").to_s(2))}.join("")
p digits

def get_version_sum(digits, idx)
  return [0, idx] if idx >= digits.length

  version_sum = 0

  version = digits[idx...idx+3].to_i(2)
  p "idx: #{idx}, digits length: #{digits.length}"
  p "version: #{version}"
  version_sum += version
  type_id = digits[idx+3...idx+6].to_i(2)
  p "type_id: #{type_id}"

  if type_id == 4
    idx += 6
    while true
      five_bits = digits[idx...idx+5]
      idx += 5
      if five_bits[0] == "0"
        break
      end
    end
  else
    length_type_id = digits[idx+6].to_i(2)
    p "length_type_id: #{length_type_id}, idx: #{idx}"

    if length_type_id == 0
      length = digits[idx+7...idx+22].to_i(2)
      idx += 22
      e_pos = idx + length
      while idx < e_pos
        sub_version_sum, idx = get_version_sum(digits, idx)
        version_sum += sub_version_sum
      end
    else
      sub_packet_number = digits[idx+7...idx+18].to_i(2)
      p "sub_packet_number: #{sub_packet_number}"
      idx += 18

      cnt = 0
      while cnt < sub_packet_number
        sub_version_sum, idx = get_version_sum(digits, idx)
        version_sum += sub_version_sum
        cnt += 1
      end
    end
  end

  [version_sum, idx]
end

# part one
# version_sum, _ = get_version_sum(digits, 0)
# p version_sum

def get_expression_value(digits, idx)
  return 0 if idx >= digits.length

  p "idx: #{idx}, digits length: #{digits.length}"
  type_id = digits[idx+3...idx+6].to_i(2)
  p "type_id: #{type_id}"

  if type_id == 4
    literal_value_bits = ""
    idx += 6
    while true
      five_bits = digits[idx...idx+5]
      literal_value_bits += five_bits[1..-1]
      idx += 5
      if five_bits[0] == "0"
        break
      end
    end

    p "literal_value_bits: #{literal_value_bits}"
    return [literal_value_bits.to_i(2), idx]
  else
    length_type_id = digits[idx+6].to_i(2)
    p "length_type_id: #{length_type_id}, idx: #{idx}"
    sub_packet_values = []

    if length_type_id == 0
      length = digits[idx+7...idx+22].to_i(2)
      idx += 22
      e_pos = idx + length

      while idx < e_pos
        sub_packet_value, idx = get_expression_value(digits, idx)
        sub_packet_values << sub_packet_value
      end
    else
      sub_packet_number = digits[idx+7...idx+18].to_i(2)
      p "sub_packet_number: #{sub_packet_number}"
      idx += 18

      cnt = 0
      while cnt < sub_packet_number
        sub_packet_value, idx = get_expression_value(digits, idx)
        p "sub_packet_value: #{sub_packet_value}"
        sub_packet_values << sub_packet_value
        cnt += 1
      end

    end
  end

  p sub_packet_values
  p type_id

  if type_id == 0
    [sub_packet_values.inject(0) {|r, v| r + v}, idx]
  elsif type_id == 1
    [sub_packet_values.inject(1) {|r, v| r * v}, idx]
  elsif type_id == 2
    [sub_packet_values.min, idx]
  elsif type_id == 3
    [sub_packet_values.max, idx]
  elsif type_id == 5
    [sub_packet_values[0] > sub_packet_values[1] ? 1 : 0, idx]
  elsif type_id == 6
    [sub_packet_values[0] < sub_packet_values[1] ? 1 : 0, idx]
  elsif type_id == 7
    [sub_packet_values[0] == sub_packet_values[1] ? 1 : 0, idx]
  end
end

value, _ = get_expression_value(digits, 0)
p value

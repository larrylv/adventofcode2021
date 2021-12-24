#!/usr/bin/env ruby

require 'pqueue'
require 'set'

MAX_NUMBER = 1 << 64

lines = File.readlines(ARGV[0]).map(&:strip)

def is_number?(v)
  !v.include?("w") && !v.include?("z")
end

def set(key, value, h, w_idx)
  if %w(x y z).include?(key)
    h[key] = value
  else
    h["w#{w_idx}"] = value
  end
end

def value_greater_than_ten?(value)
  if value.include?(" + ")
    value.split(" + ").last.to_i >= 10
  elsif is_number?(value)
    value.to_i >= 10
  else
    false
  end
end

def resolve(key, h, w_idx)
  if key.include?("x") || key.include?("y") || key.include?("z") || key.include?("w")
    if %w(x y).include?(key)
      h[key]
    elsif key.include?("z")
      h["z"]
    else
      h["w#{w_idx}"]
    end
  else
    key
  end
end

def execute(op, a, b, h, w_idx)
  lhs = resolve(a, h, w_idx)
  rhs = resolve(b, h, w_idx)

  if is_number?(lhs) && is_number?(rhs)
    if op == "add"
      set(a, (lhs.to_i + rhs.to_i).to_s, h, w_idx)
    elsif op == "mul"
      set(a, (lhs.to_i * rhs.to_i).to_s, h, w_idx)
    elsif op == "div"
      set(a, (lhs.to_i / rhs.to_i).to_s, h, w_idx)
    elsif op == "mod"
      set(a, (lhs.to_i % rhs.to_i).to_s, h, w_idx)
    elsif op == "eql"
      set(a, (lhs == rhs ? 1 : 0).to_s, h, w_idx)
    end
  else
    if op == "add"
      if is_number?(lhs) && lhs.to_i == 0
        value = rhs
      elsif is_number?(rhs) && rhs.to_i == 0
        value = lhs
      else
        value = "(#{lhs} + #{rhs})"
      end
      set(a, value, h, w_idx)
    elsif op == "mul"
      if is_number?(lhs) && lhs.to_i == 0
        value = "0"
      elsif is_number?(rhs) && rhs.to_i == 0
        value = "0"
      elsif is_number?(lhs) && lhs.to_i == 1
        value = rhs
      elsif is_number?(rhs) && rhs.to_i == 1
        value = lhs
      else
        value = "(#{lhs} * #{rhs})"
      end
      set(a, value, h, w_idx)
    elsif op == "div"
      if is_number?(rhs) && rhs.to_i == 1
        value = lhs
      elsif is_number?(lhs) && lhs.to_i == 0
        value = "0"
      else
        value = "(#{lhs} / #{rhs})"
      end
      set(a, value, h, w_idx)
    elsif op == "mod"
      # require 'pry'; binding.pry
      if is_number?(rhs) && rhs.to_i == 1
        value = "0"
      elsif is_number?(lhs) && lhs.to_i == 0
        value = "0"
      else
        value = "(#{lhs} % #{rhs})"
      end
      set(a, value, h, w_idx)
    elsif op == "eql"
      if lhs == rhs
        value = "1"
      else
        if value_greater_than_ten?(lhs)
          value = "0"
        else
          value = "(#{lhs} == #{rhs} ? 1 : 0)"
        end
      end
      set(a, value, h, w_idx)
    end
  end
end

# part one

h = {
  "x" => "0",
  "y" => "0",
  "z" => "0"
}
(0...14).map do |idx|
  h["w#{idx}"] = "w#{idx}"
end

z_h = {"z0" => "0"}

w_idx = -1
z_idx = -1
lines.each_with_index do |line, idx|
  op, a, b = line.split(" ")
  if op == "inp"
    w_idx += 1
    z_idx += 1
    z_h["z#{z_idx}"] = h["z"]
    p h["z"]
    h["z"] = "z#{z_idx}" if z_idx != 0
    next
  end


  a = "w[#{w_idx}]" if a == "w"
  b = "w[#{w_idx}]" if b == "w"

  execute(op, a, b, h, w_idx)
  p "line: #{idx}, op: #{op}, a: #{a}, b: #{b}"
end

z_h.each do |k, v|
  p "#{k}: #{v}"
end
p "z14: #{h["z"]}"

# "z0: 0"
# "z1: (w0 + 15)"
# "z2: ((z1 * 26) + (w1 + 12))"
# "z3: ((z2 * 26) + (w2 + 15))"
# "z4: (((z3 / 26) * ((25 * ((((z3 % 26) + -9) == w3 ? 1 : 0) == 0 ? 1 : 0)) + 1)) + ((w3 + 12) * ((((z3 % 26) + -9) == w3 ? 1 : 0) == 0 ? 1 : 0)))"
#      (((z2     ) * ((25 * ((((w2 + 15) + -9) == w3 ? 1 : 0) == 0 ? 1 : 0)) + 1)) + ((w3 + 12) * ((((w2 + 15) + -9) == w3 ? 1 : 0) == 0 ? 1 : 0)))"
# "z5: (((z4 / 26) * ((25 * ((((z4 % 26) + -7) == w4 ? 1 : 0) == 0 ? 1 : 0)) + 1)) + ((w4 + 15) * ((((z4 % 26) + -7) == w4 ? 1 : 0) == 0 ? 1 : 0)))"
# "z6: ((z5 * 26) + (w5 + 2))"
# "z7: (((z6 / 26) * ((25 * ((((z6 % 26) + -1) == w6 ? 1 : 0) == 0 ? 1 : 0)) + 1)) + ((w6 + 11) * ((((z6 % 26) + -1) == w6 ? 1 : 0) == 0 ? 1 : 0)))"
# "z8: (((z7 / 26) * ((25 * ((((z7 % 26) + -16) == w7 ? 1 : 0) == 0 ? 1 : 0)) + 1)) + ((w7 + 15) * ((((z7 % 26) + -16) == w7 ? 1 : 0) == 0 ? 1 : 0)))"
# "z9: ((z8 * 26) + (w8 + 10))"
# "z10: (((z9 / 26) * ((25 * ((((z9 % 26) + -15) == w9 ? 1 : 0) == 0 ? 1 : 0)) + 1)) + ((w9 + 2) * ((((z9 % 26) + -15) == w9 ? 1 : 0) == 0 ? 1 : 0)))"
#       (((z8     ) * ((25 * ((((w8 + 10) + -15) == w9 ? 1 : 0) == 0 ? 1 : 0)) + 1)) + ((w9 + 2) * ((((w8 + 10) + -15) == w9 ? 1 : 0) == 0 ? 1 : 0)))"
# "z11: ((z10 * 26) + w10)"
# "z12: ((z11 * 26) + w11)"
# "z13: (((z12 / 26) * ((25 * ((((z12 % 26) + -4) == w12 ? 1 : 0) == 0 ? 1 : 0)) + 1)) + ((w12 + 15) * ((((z12 % 26) + -4) == w12 ? 1 : 0) == 0 ? 1 : 0)))"
#       (((z11     ) * ((25 * ((((w11     ) + -4) == w12 ? 1 : 0) == 0 ? 1 : 0)) + 1)) + ((w12 + 15) * ((((w11     ) + -4) == w12 ? 1 : 0) == 0 ? 1 : 0)))"
# "z14: (((z13 / 26) * ((25 * (((z13 % 26) == w13 ? 1 : 0) == 0 ? 1 : 0)) + 1)) + ((w13 + 15) * (((z13 % 26) == w13 ? 1 : 0) == 0 ? 1 : 0)))"

# z14 == 0


# z14 -> z13/w13
# z13 -> z11/w11/w12
# z11 -> z10/w10
# z10 -> z8/w8/w9
# z8  -> z7/w7
# z7  -> z6/w6
# z6  -> z5/w5
# z5  -> z4/w4
# z4  -> z2/w2/w3
# z3  -> z2/w2
# z2  -> z1/w1
# z1  -> w0


# part two

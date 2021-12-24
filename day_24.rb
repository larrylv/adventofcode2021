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
#      (((z5     ) * ((25 * ((((w5 + 2 ) + -1) == w6 ? 1 : 0) == 0 ? 1 : 0)) + 1)) + ((w6 + 11) * ((((w5 + 2 ) + -1) == w6 ? 1 : 0) == 0 ? 1 : 0)))"
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

# no way any z could be negative, so:
# with z14 being 0, its lhs and rhs for the `add` op should be 0:
#   * z13 < 26
#   * z13 % 26 == w13 -> z13 in range (1..9)
#
# for z13, its right side of the `add` op which is `(w12 + 15) multiply sth` has to be 0:
#   * w11 - 4 = w12 (yay!)
# for z13, its left side of the `add` op needs to be in range (1..9), and given z11 is positive,
#   * `((25 * ((((w11     ) + -4) == w12 ? 1 : 0) == 0 ? 1 : 0)) + 1)` has to be 1
#   * which confirmed `w11 - 4 = w12`
#
# this also means z13 = z11
#   z13 % 26 == w13
#   z11 % 26 == w10
# so w13 == w10 (yay!!)
#
# this also means z11 < 26, which means z10 == 0
#   lhs: z8 == 0
#   rhs: w8 - 5 == w9 (yay!!!)
#
# with z8 being 0,
#   lhs: z7 < 26
#   rhs: z7 - 16 == w7, -> z7 in range (17..25)

# z7 in range (17..25),
#   option 1. z5 is 0, and (w5 + 1 != w6), and w6 in range (6..9)
#     * z7 == w6 + 11
#     * so, w6 - 5 == w7
#     goto: 27A // this is not happening, cut the search (see 27A)
#   option 2. z5 is not 0, but (w5 + 1 == w6), and z5 in range (17..25)
#     * w5 + 1 == w6 (yay!!!!)
#     goto: Z7_B // this is the only option
#

# 27A:
#   z5 == 0
#     rhs: z4 % 26 - 7 == w4
#     lhs: z4 / 26 == 0
#     so, z4 - 7 == w4 ------ no way this can be true, as z4 is guarantteed to be much bigger than 26
#

# Z7B:
#   z5 in range (17..25)
#     given z4 is guarantteed to be bigger than 26, so lhs `z4/26` can't be 0.
#       so, z4 % 26 - 7 == w4
#
#     z4 % 26:
#     option 1: w2 + 6 == w3 (yay!!!!!)
#       z4 % 26 == z2 % 26 == w1 + 12, so w1 + 12 - 7 == w4 (yay!!!!!)
#     option 2: w2 + 6 != w3 ------ (this proves not possible, but i'm too lazy to capture details)

def execute_lines(lines, h)
  w_idx = -1
  lines.each_with_index do |line, idx|
    op, a, b = line.split(" ")
    if op == "inp"
      w_idx += 1
      next
    end


    a = "w[#{w_idx}]" if a == "w"
    b = "w[#{w_idx}]" if b == "w"

    execute(op, a, b, h, w_idx)
  end
end


result = []

(1..9).each do |m_0|
  (1..4).each do |m_1|
    m_4 = m_1 + 5
    (1..3).each do |m_2|
      m_3 = m_2 + 6
      (1..8).each do |m_5|
        m_6 = m_5 + 1
        (1..9).each do |m_7|
          (6..9).each do |m_8|
            m_9 = m_8 - 5
            (1..9).each do |m_10|
              m_13 = m_10
              (5..9).each do |m_11|
                m_12 = m_11 - 4

                model_number = [
                  m_0,
                  m_1,
                  m_2,
                  m_3,
                  m_4,
                  m_5,
                  m_6,
                  m_7,
                  m_8,
                  m_9,
                  m_10,
                  m_11,
                  m_12,
                  m_13,
                ].map(&:to_s)
                h = {
                  "x" => "0",
                  "y" => "0",
                  "z" => "0",
                }
                model_number.each_with_index do |n, idx|
                  h["w#{idx}"] = n
                end
                execute_lines(lines, h)
                if h["z"].to_s == "0"
                  result << model_number.join("")
                  p 'found'
                  p result.last
                end
              end
            end
          end
        end
      end
    end
  end
end

p result.max

# part two

p result.min

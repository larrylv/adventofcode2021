#!/usr/bin/env ruby

require 'pqueue'
require 'set'

MAX_NUMBER = 1 << 64

def pixel_value(pixels)
  pixels.chars.map {|pixel| pixel == "#" ? "1" : "0"}.join.to_i(2)
end

def calculate_pixel(input_image, i, j, image_enhancement)
  pixels = [-1, 0, 1].map do |i_offset|
    [-1, 0, 1].map {|j_offset| input_image[i+i_offset][j+j_offset]}.join("")
  end.join("")

  image_enhancement[pixel_value(pixels)]
end

def initialize_image(row, column, pixel)
  image = []
  (0...row).each do |i|
    image[i] = []
    (0...column).each {|j| image[i][j] = pixel}
  end
  image
end

def enhance_image(input_image, image_enhancement, default_pixel)
  output_image = initialize_image(input_image.size, input_image[0].size, default_pixel)

  (1...input_image.size-1).each do |i|
    (1...input_image[0].size-1).each do |j|
      output_image[i][j] = calculate_pixel(input_image, i, j, image_enhancement)
    end
  end

  output_image
end

def count_lit_pixel(input_image)
  input_image.sum { |row| row.count {|p| p == "#"} }
end

def add_additional_rows_and_columns(input_image, additional_cnt, default_pixel)
  new_row_cnt = input_image.size + additional_cnt * 2
  new_column_cnt = input_image[0].size + additional_cnt * 2
  new_input_image = initialize_image(new_row_cnt, new_column_cnt, default_pixel)

  (0...input_image.size).each do |i|
    (0...input_image[0].size).each do |j|
      new_input_image[i+additional_cnt][j+additional_cnt] = input_image[i][j]
    end
  end

  new_input_image
end

def print_image(image)
  image.each do |row|
    puts row.join("")
  end
end

lines = File.readlines(ARGV[0]).map(&:strip)
image_enhancement = lines[0]
input_image = lines[2..-1].map {|line| line.split("")}

# print_image(input_image)

default_pixel = "."
# part one
2.times do |idx|
  input_image = add_additional_rows_and_columns(input_image, 2, default_pixel)
  p "applying image enhancement: #{idx+1} times"
  p "original:"
  print_image(input_image)
  default_pixel = default_pixel == "#" ? image_enhancement[511] : image_enhancement[0]
  input_image = enhance_image(input_image, image_enhancement, default_pixel)
  p "after:"
  print_image(input_image)
end

p count_lit_pixel(input_image)

# part two
48.times do |idx|
  input_image = add_additional_rows_and_columns(input_image, 2, default_pixel)
  default_pixel = default_pixel == "#" ? image_enhancement[511] : image_enhancement[0]
  input_image = enhance_image(input_image, image_enhancement, default_pixel)
end

p count_lit_pixel(input_image)

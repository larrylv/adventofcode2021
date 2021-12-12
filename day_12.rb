#!/usr/bin/env ruby

require 'set'

lines = File.readlines(ARGV[0]).map(&:strip)

def build_graph(lines)
  graph = Hash.new {|h, k| h[k] = Set.new}

  lines.each do |line|
    a, b = line.split("-")
    graph[a].add(b)
    graph[b].add(a)
  end

  graph
end

def is_small_cave?(cave)
  cave.chars.all? {|char| char >= "a" && char <= "z"}
end

def count_path(cave, graph, path_map)
  return 1 if cave == "end"

  graph[cave].inject(0) do |cnt, cave|
    next cnt if cave == "start"

    if is_small_cave?(cave)
      if path_map[cave] == 0
        cnt += count_path(cave, graph, path_map.merge({cave => 1}))
      else # part 2
        next cnt if path_map.select{|k, v| is_small_cave?(k)}.values.uniq.include?(2)
        cnt += count_path(cave, graph, path_map.merge({cave => 2}))
      end
    else
      cnt += count_path(cave, graph, path_map.merge({cave => 1}))
    end

    cnt
  end
end

path_map = Hash.new {|h, k| h[k] = 0}
p count_path("start", build_graph(lines), path_map)

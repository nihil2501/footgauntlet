#!/usr/bin/env ruby

dir = File.expand_path("../../../lib", __dir__)
unless $LOAD_PATH.include?(dir)
  $LOAD_PATH.unshift(dir)
end

# frozen_string_literal: true

require "footgauntlet/shell/processor"

class Options
  DIR = File.expand_path("../../fixtures", __dir__)

  def input_stream
    @input_stream ||= open_file("input.txt", "r")
  end

  def output_stream
    @output_stream ||= open_file("output-actual.txt", "w")
  end

  def open_file(name, mode)
    path = File.expand_path(name, DIR)
    File.open(path, mode)
  end
end

options = Options.new
Footgauntlet::Shell::Processor.start(options)

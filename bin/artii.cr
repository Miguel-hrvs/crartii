#!/usr/bin/env ruby

require "../lib/artii.cr"

begin
  a = Artii::CLI.new ARGV.dup
  puts a.output
rescue e : Exception
  puts "Something has gone horribly wrong!"
  puts "Artii says: #{e.message}"
  # puts e.backtrace
end

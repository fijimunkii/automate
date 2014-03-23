#!/usr/bin/env ruby

require_relative 'wdma'
require 'optparse'

OptionParser.new do |opts|
  opts.banner = "Usage: init.rb [options]"

  opts.on("-h", "--help", "Help.") do |v|
    p opts.banner
  end

  opts.on("-s", "--scrape", "Run scrape.") do |v|
    WDMA.scrape
  end

  opts.on("-w", "--watch", "Start watching.") do |v|
    WDMA.watch
  end

  opts.on("-u", "--upload", "Upload torrent.") do |v|
    WDMA.upload v
  end
end.parse!

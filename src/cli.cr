require "option_parser"
require "./domo"

parser = OptionParser.new do |parser|
  parser.banner = "usage: domo"

  parser.on("-v", "--version", "display the version") { puts Domo::VERSION; exit 0 }
  parser.on("-h", "--help", "show this help") { puts parser; exit 0 }
end

parser.parse!

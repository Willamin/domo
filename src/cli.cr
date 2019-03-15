require "option_parser"
require "./domo"

verbose_tokenize = false
verbose_parse = false

parser = OptionParser.new do |parser|
  parser.banner = "usage: domo"

  parser.on("-v", "--version", "display the version") { puts Domo::VERSION; exit 0 }
  parser.on("-h", "--help", "show this help") { puts parser; exit 0 }

  parser.on("--vt", "verbosely expose tokens") { verbose_tokenize = true }
  parser.on("--vp", "verbosely expose parse steps") { verbose_parse = true }

  parser.unknown_args { |args| ARGV.replace(args) }
end

parser.parse!
ARGV.each { |arg| Domo.parse_from_file(arg, verbose_tokenize, verbose_parse) }

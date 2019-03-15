require "./domo/*"

module Domo
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  def self.parse_from_file(filename, verbose_tokenize = false, verbose_parse = false)
    Domo::Parser.from_file(filename)
      .tokenize(verbose_tokenize)
      .parse(verbose_parse)
      .check_for_invalid
      .print_structure
  end
end

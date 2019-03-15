require "./domo/*"

module Domo
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  def self.parse_from_file(filename, verbose_tokenize, verbose_parse)
    Domo::Parser.from_file(filename)
      .tokenize(verbose_tokenize)
      .parse(verbose_parse)
      .check_for_invalid
  end
end

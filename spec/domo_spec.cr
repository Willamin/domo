require "./spec_helper"

describe Domo do
  test "that it works on a snapshot" do
    actual = String.build do |s|
      Domo::Parser.from_file("./sample")
        .tokenize
        .parse
        .check_for_invalid
        .print_structure(s)
    end

    expected = <<-EOF
      Instrument : Electric | Acoustic | Bass | Ukelele
      Electric
      Acoustic
      Bass
      Ukelele
      Course :: .instrument : Instrument, .song : Song
      Song
      Lesson :: .video : Video
      Video

      EOF

    assert actual == expected
  end
end

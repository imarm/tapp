require 'pry'
require_relative 'lib/tapp.rb'

source = ARGV[0]
if source == '-'
  stream = $stdin
else
  stream = File.open(source)
end

tapp = Tapp.new(stream)
tapp.read_header
audiowaveform_data = tapp.read_body



threshold = 3
phase = :down

seq = 1
prev = 0
rep = 0
_found = 0
audiowaveform_data.each do |one|
  max = one['max_0']

  if phase == :down
    if max > prev
      rep += 1
    else
      rep = 0
    end
  else
    if max < prev
      rep += 1
    else
      rep = 0
    end
  end

  marker = 1 # grey
  if rep == threshold
    rep = 0
    phase = phase == :up ? :down : :up

    if phase == :down
      marker = 2 # red
      _found += 1
    end
  end

  printf "%d %d %d\n", seq += 1, max, marker
  # printf "%5d %7d %7d %d %d %s %s\n", seq += 1, max, prev, marker, rep, phase.to_s, marker == 2 ? 'found' : ''

  prev = max
end

printf "found: %d", _found

require 'bindata'
require 'pry'

VERSION_FLAG_1 = 1
VERSION_FLAG_2 = 2

class Tapp
  class Header_1 < BinData::Record
    endian :little
    uint32 :flags
    int32 :sample_rate
    int32 :per_pixel
    uint32 :data_length
  end

  class Header_2 < BinData::Record
    endian :little
    uint32 :flags
    int32 :sample_rate
    int32 :per_pixel
    uint32 :data_length
    int32 :channels
  end
end


## main loop
source = ARGV[0]
if source == '-'
  stream = $stdin
else
  stream = File.open(source)
end

# read version header
version_field = stream.read(4)
version = version_field.reverse.unpack('N').first

case version
when VERSION_FLAG_1 then
  structure = Tapp::Header_1
when VERSION_FLAG_2 then
  structure = Tapp::Header_2
end

# read entire header
header = structure.read(stream)

if false
p 'flags: %d' % header.flags
p 'sample_rate: %d' % header.sample_rate
p 'per_pixel: %d' % header.per_pixel
p 'length: %d' % header.data_length

if version == 2
  p 'channels: %d' % header.channels
else
  p 'channels: no'
end
end

# read data
bindata_type = header.flags == 0 ? 'int16le' : 'int8'

channels = version == 2 ? header.channels : 1

fields = []
channels.times do |i|
  fields.push([bindata_type.to_sym, ('min_%d' % i).to_sym])
  fields.push([bindata_type.to_sym, ('max_%d' % i).to_sym])
end

BinData::Struct.new(name: :unit,
                    fields: fields)

data_field = BinData::Array.new(type: :unit, initial_length: header.data_length)
data = data_field.read(stream)

threshold = 3
phase = :down

seq = 1
prev = 0
rep = 0
_found = 0
data.each do |one|
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

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

p 'flags: %d' % header.flags
p 'sample_rate: %d' % header.sample_rate
p 'per_pixel: %d' % header.per_pixel
p 'length: %d' % header.data_length

if version == 2
  p 'channels: %d' % header.channels
else
  p 'channels: no'
end

# read data
resolution = header.flags == 0 ? 16 : 8
bindata_type = 'int%d' % resolution

class Tapp
  class Data < BinData::Record
    header.channels.times do |i|
      # int8 :channel_i
      # としたい

      # int8 を動的にコールするには
      self.send(bindata_type, 'min_%d' % i)
      self.send(bindata_type, 'max_%d' % i)
    end
  end
end

binding.pry

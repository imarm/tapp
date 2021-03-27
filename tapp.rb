require 'bindata'

VERSION_FLAG_1 = 1
VERSION_FLAG_2 = 2

class Tapp
  class Header_1 < BinData::Record
    endian :little
    uint32 :flags
    int32 :sample_rate
    int32 :samples
    uint32 :length
  end

  class Header_2 < BinData::Record
    endian :little
    uint32 :flags
    int32 :sample_rate
    int32 :samples
    uint32 :length
    int32 :channels
  end
end


## main loop

# read version
$stdin.each_byte.each_slice(4) do |bytes|
  version = bytes
end

case version
when VERSION_FLAG_1 then
  structure = Header_1
when VERSION_FLAG_2 then
  structure = Header_2
end

# read header
header = structure.read($stdin)

p header.flags
p header.sample_rate
p header.samples
p header.length
p header.channels

# read data

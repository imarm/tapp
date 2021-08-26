require 'bindata'

class Tapp
  VERSION_FLAG_1 = 1
  VERSION_FLAG_2 = 2

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

  attr_accessor :stream, :header

  def initialize(stream)
    @stream = stream
  end

  def read_header
    version = read_version
    structure = header_structure(version)
    @header = structure.read(@stream)
  end

  def body_structure
    fields = []
    channels.times do |i|
      fields.push([data_type.to_sym, ('min_%d' % i).to_sym])
      fields.push([data_type.to_sym, ('max_%d' % i).to_sym])
    end

    BinData::Struct.new(name: :unit,
                        fields: fields)
    BinData::Array.new(type: :unit, initial_length: @header.data_length)
  end

  def read_body
    structure = body_structure
    structure.read(@stream)
  end

  private
  def read_version
    version_field = @stream.read(4)
    version_field.reverse.unpack('N').first
  end

  def header_structure(version)
    case version
    when VERSION_FLAG_1 then
      Tapp::Header_1
    when VERSION_FLAG_2 then
      Tapp::Header_2
    end
  end

  def data_type
    @header.flags == 0 ? 'int16le' : 'int8'
  end

  def channels
    VERSION_FLAG_1 ? 1 : @header.channels
  end
end

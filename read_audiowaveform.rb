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
tapp.parse(audiowaveform_data)

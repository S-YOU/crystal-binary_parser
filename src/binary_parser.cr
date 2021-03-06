require "./binary_parser/macros/*"

# BinaryParser for Crystal
#
# ```crystal
# class Parser < BinaryParser
#   uint8 :value
# end
#
# io = IO::Memory.new(sizeof(UInt8))
# io.write_bytes(42)
# io.rewind
# parser = Parser.new.load(io)
#
# parser.value # 42
# ```
#
class BinaryParser
  # Load from file with `filename`
  #
  def load(filename : String, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
    io = File.open(filename)
    load(io, format)
  end

  # Load from an IO object
  #
  def load(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
    {% for method in @type.methods %}
      {% if method.name.starts_with?("_read_") %}
        {{method.name}}(io, format)
      {% end %}
    {% end %}
    self
  end

  # Save to file with `filename`
  #
  def save(filename : String, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
    io = File.open(filename, "w")
    write(io, format)
  end

  # Convert to string
  #
  # ```crystal
  # File.write("filename", parser)
  # ```
  #
  def to_s(io : IO)
    write(io)
  end

  # Write to an IO object
  #
  def write(io : IO, format : IO::ByteFormat = IO::ByteFormat::SystemEndian)
    {% for method in @type.methods %}
      {% if method.name.starts_with?("_write_") %}
        {{method.name}}(io, format)
      {% end %}
    {% end %}
    self
  end

  # Support for `IO#read_bytes`
  #
  def self.from_io(io : IO, format : IO::ByteFormat)
    ins = self.new
    ins.load(io, format)
  end

  # Support for `IO#write_bytes`
  #
  def to_io(io : IO, format : IO::ByteFormat)
    write(io, format)
  end
end

require "./binary_parser/byte_size"

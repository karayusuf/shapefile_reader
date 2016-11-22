require_relative 'main_file_header'
require_relative 'record_header'

require_relative 'shapes/null'
require_relative 'shapes/point'
require_relative 'shapes/polygon'

require 'pp'
require 'pry'

module Shapefile
  class Reader

    UNPACK_INTEGER = { big: 'N', little: 'V' }
    UNPACK_DOUBLE  = { big: 'G', little: 'E' }

    BYTESIZE_INTEGER = 4
    BYTESIZE_DOUBLE = 8

    FIRST_RECORD_OFFSET = MainFileHeader::BYTES

    attr_reader :file, :main_file_header

    def initialize(filepath)
      @file = filepath
      @main_file_header = parse_main_file_header
    end

    def each_record(&block)
      (0..Float::INFINITY).lazy.reduce(FIRST_RECORD_OFFSET) do |record_offset, previous_record_number|
        break if record_offset >= main_file_header.file_length

        header, shape = parse_record(file, record_offset)
        block.call(header, shape)

        header.content_length + 8 + record_offset
      end
    end

    private

    def parse_main_file_header
      File.open(@file) do |file|
        main_file_header = MainFileHeader.new

        main_file_header.file_code   = parse_int(file: file, position: 0,  byte_order: :big)
        main_file_header.file_length = parse_int(file: file, position: 24, byte_order: :big) * 2
        main_file_header.version     = parse_int(file: file, position: 28, byte_order: :little)
        main_file_header.shape_type  = parse_int(file: file, position: 32, byte_order: :little)

        main_file_header.x_min = parse_double(file: file, position: 36, byte_order: :little)
        main_file_header.y_min = parse_double(file: file, position: 44, byte_order: :little)
        main_file_header.x_max = parse_double(file: file, position: 52, byte_order: :little)
        main_file_header.y_max = parse_double(file: file, position: 60, byte_order: :little)

        main_file_header.z_min = parse_double(file: file, position: 68, byte_order: :little)
        main_file_header.z_max = parse_double(file: file, position: 76, byte_order: :little)
        main_file_header.m_min = parse_double(file: file, position: 84, byte_order: :little)
        main_file_header.m_max = parse_double(file: file, position: 92, byte_order: :little)

        main_file_header
      end
    end

    def parse_record(file, offset)
      File.open(@file) do |file|
        record_header = RecordHeader.new
        record_header.record_number  = parse_int(file: file, position: offset,     byte_order: :big)
        record_header.content_length = parse_int(file: file, position: offset + 4, byte_order: :big) * 2
        record_header.shape_type     = parse_int(file: file, position: offset + 8, byte_order: :little)

        polygon = parse_polygon(file, offset + 8)
        [record_header, polygon]
      end
    end

    def parse_polygon(file, offset)
      polygon = Shapes::Polygon.new
      polygon.x_min = parse_double(file: file, position: offset + 4, byte_order: :little)
      polygon.y_min = parse_double(file: file, position: offset + 12, byte_order: :little)
      polygon.x_max = parse_double(file: file, position: offset + 20, byte_order: :little)
      polygon.y_max = parse_double(file: file, position: offset + 28, byte_order: :little)

      polygon.num_parts = parse_int(file: file, position: offset + 36, byte_order: :little)
      polygon.num_parts.times.reduce(offset + 44) do |part_offset|
        polygon.add_part(parse_int(file: file, position: part_offset, byte_order: :little))
        part_offset + BYTESIZE_INTEGER
      end

      polygon.num_points = parse_int(file: file, position: offset + 40, byte_order: :little)
      polygon.num_points.times.reduce(offset + 44 + 4 * polygon.num_parts) do |point_offset|
        point = Shapes::Point.new
        point.x = parse_double(file: file, position: point_offset, byte_order: :little)
        point.y = parse_double(file: file, position: point_offset + BYTESIZE_DOUBLE, byte_order: :little)

        polygon.add_point(point)
        point_offset + (2 * BYTESIZE_DOUBLE)
      end

      polygon
    end

    def parse_int(file:, position:, byte_order:)
      file.pos = position
      byte_value = file.read(BYTESIZE_INTEGER)
      byte_value.unpack(UNPACK_INTEGER[byte_order]).first
    end

    def parse_double(file:, position:, byte_order:)
       file.pos = position
       byte_value = file.read(BYTESIZE_DOUBLE)
       byte_value.unpack(UNPACK_DOUBLE[byte_order]).first
    end

  end
end


require_relative './models/main_file_header'
require_relative './models/record_header'
require_relative './models/shapes/polygon'
require_relative './models/shapes/point'

require 'pry'

module Shapefile
  class Parser

    UNPACK_INTEGER = { big: 'N', little: 'V' }
    UNPACK_DOUBLE  = { big: 'G', little: 'E' }

    BYTESIZE_INTEGER = 4
    BYTESIZE_DOUBLE = 8

    attr_reader :file

    def initialize(file)
      @file = file
    end

    def parse
      main_file_header = parse_main_file_header
      first_entry = parse_record(100)
      first_entry

    #    headers = []
    #    100.times.reduce(100) do |offset|
    #      header, shape = parse_record(offset)
    #      headers << [offset, header, shape]
    #      header.content_length + offset + 8
    #    end
    end

    def parse_main_file_header
      main_file_header = MainFileHeader.new

      main_file_header.file_code   = parse_int(position: 0,  byte_order: :big)
      main_file_header.file_length = parse_int(position: 24, byte_order: :big) * 2
      main_file_header.version     = parse_int(position: 28, byte_order: :little)
      main_file_header.shape_type  = parse_int(position: 32, byte_order: :little)

      main_file_header.x_min = parse_double(position: 36, byte_order: :little)
      main_file_header.y_min = parse_double(position: 44, byte_order: :little)
      main_file_header.x_max = parse_double(position: 52, byte_order: :little)
      main_file_header.y_max = parse_double(position: 60, byte_order: :little)

      main_file_header.z_min = parse_double(position: 68, byte_order: :little)
      main_file_header.z_max = parse_double(position: 76, byte_order: :little)
      main_file_header.m_min = parse_double(position: 84, byte_order: :little)
      main_file_header.m_max = parse_double(position: 92, byte_order: :little)

      main_file_header
    end

    def parse_record(offset)
      record_header = RecordHeader.new
      record_header.record_number  = parse_int(position: offset,     byte_order: :big)
      record_header.content_length = parse_int(position: offset + 4, byte_order: :big) * 2
      record_header.shape_type     = parse_int(position: offset + 8, byte_order: :little)

      polygon = parse_polygon(offset + 8)
      [record_header, polygon]
    end

    def parse_polygon(offset)
      polygon = Shapes::Polygon.new
      polygon.x_min = parse_double(position: offset + 4, byte_order: :little)
      polygon.y_min = parse_double(position: offset + 12, byte_order: :little)
      polygon.x_max = parse_double(position: offset + 20, byte_order: :little)
      polygon.y_max = parse_double(position: offset + 28, byte_order: :little)

      polygon.num_parts = parse_int(position: offset + 36, byte_order: :little)
      polygon.num_parts.times.reduce(offset + 44) do |part_offset|
        polygon.add_part(parse_int(position: part_offset, byte_order: :little))
        part_offset + BYTESIZE_INTEGER
      end

      polygon.num_points = parse_int(position: offset + 40, byte_order: :little)
      polygon.num_points.times.reduce(offset + 44 + 4 * polygon.num_parts) do |point_offset|
        point = Shapes::Point.new
        point.x = parse_double(position: point_offset, byte_order: :little)
        point.y = parse_double(position: point_offset + BYTESIZE_DOUBLE, byte_order: :little)

        polygon.add_point(point)
        point_offset + (2 * BYTESIZE_DOUBLE)
      end

      polygon
    end

    private

    def parse_int(position:, byte_order:)
      byte_value = File.binread(@file, BYTESIZE_INTEGER, position)
      byte_value.unpack(UNPACK_INTEGER[byte_order]).first
    end

    def parse_double(position:, byte_order:)
      byte_value = File.binread(@file, BYTESIZE_DOUBLE, position)
      byte_value.unpack(UNPACK_DOUBLE[byte_order]).first
    end

  end
end


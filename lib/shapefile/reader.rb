require_relative 'main_file_header'
require_relative 'record_header'

require_relative 'shapes/null'
require_relative 'shapes/point'
require_relative 'shapes/polygon'

require 'pp'
require 'pry'

module Shapefile
  class Reader

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

    def parse_main_file_header
      bytes = File.binread(@file, 100)
      fields = bytes.unpack('N7V2E8')

      main_file_header = MainFileHeader.new
      main_file_header.file_code   = fields[0]
      main_file_header.file_length = fields[6] * 2
      main_file_header.version     = fields[7]
      main_file_header.shape_type  = fields[8]

      main_file_header.x_min = fields[9]
      main_file_header.y_min = fields[10]
      main_file_header.x_max = fields[11]
      main_file_header.y_max = fields[12]

      main_file_header.z_min = fields[13]
      main_file_header.z_max = fields[14]
      main_file_header.m_min = fields[15]
      main_file_header.m_max = fields[16]

      main_file_header
    end

    def parse_record(file, offset)
      File.open(@file) do |file|
        fields = parse_fields(file: file, offset: offset, bytes: 12, values: 'N2V1')

        record_header = RecordHeader.new
        record_header.record_number  = fields[0]
        record_header.content_length = fields[1] * 2
        record_header.shape_type     = fields[2]

        polygon = parse_polygon(file, offset + 12)
        [record_header, polygon]
      end
    end

    def parse_polygon(file, offset)
      fields = parse_fields(file: file, offset: offset, bytes: 40, values: 'E4V2')

      polygon = Shapes::Polygon.new
      polygon.x_min = fields[0]
      polygon.y_min = fields[1]
      polygon.x_max = fields[2]
      polygon.y_max = fields[3]

      polygon.num_parts = fields[4]
      polygon.num_points = fields[5]

      polygon.parts = parse_fields({
        file: file,
        offset: offset + 40,
        bytes: polygon.num_parts * BYTESIZE_INTEGER,
        values: "V#{polygon.num_parts}"
      })

      point_values = parse_fields({
        file: file,
        offset: (offset + 40) + (polygon.num_parts * BYTESIZE_INTEGER),
        bytes: (polygon.num_points * BYTESIZE_DOUBLE * 2),
        values: "V#{polygon.num_points * 2}"
      })

      polygon.points = point_values.each_slice(2).map { |x, y| Shapes::Point.new(x, y) }
      polygon
    end

    private

    MAX_BYTES_AT_ONE_TIME = 2048.0
    def parse_fields(file:, offset:, bytes:, values:)
      file.pos = offset

      if bytes > MAX_BYTES_AT_ONE_TIME
        number_of_reads = (bytes / MAX_BYTES_AT_ONE_TIME).ceil
        parsed_bytes = number_of_reads.times.map { |batch_number| file.read(MAX_BYTES_AT_ONE_TIME * batch_number) }.join
        parsed_bytes.unpack(values)
      else
        parsed_bytes = file.read(bytes)
        parsed_bytes.unpack(values)
      end
    end
  end
end


require_relative './utils/model_attributes'

module Shapefile
  class RecordHeader
    attr_accessor :record_number
    attr_accessor :content_length
    attr_accessor :shape_type
  end
end

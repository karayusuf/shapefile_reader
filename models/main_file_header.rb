require_relative './utils/model_attributes'

module Shapefile
  class MainFileHeader
   attr_accessor :file_code
   attr_accessor :file_length
   attr_accessor :version
   attr_accessor :shape_type
   attr_accessor :x_min
   attr_accessor :y_min
   attr_accessor :x_max
   attr_accessor :y_max
   attr_accessor :z_min
   attr_accessor :z_max
   attr_accessor :m_min
   attr_accessor :m_max
  end
end

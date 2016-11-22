module Shapefile
  module Shapes
    #
    # A polygon consists of one or more rings. A ring is a connected sequence of
    # four or more points that form a closed, non-self-intersecting loop. A
    # polygon may contain multiple outer rings. The order of vertices or
    # orientation for a ring indicates which side of the ring is the interior of
    # the polygon.
    #
    # The neighborhood to the right of an observer walking along the ring in
    # vertex order is the neighborhood inside the polygon. Vertices of rings
    # defining holes in polgyons are in a counterclockwise direction. Vertices
    # for a single, ringed polygon are, therefore, always in clockwise order.
    # The rings of the polygon are referred to as its parts.
    #
    # Because this specification does not forbig consecutive points with
    # identical coordinates, shapefile readers must handle such cases. On the
    # other hand, the degenerate, zero length or zero area parts that might
    # result are not allowed.
    #
    class Polygon

      attr_accessor :x_min, :x_max
      attr_accessor :y_min, :y_max

      # The number of rings in the polygon.
      attr_accessor :num_parts

      # The total number of points for all rings.
      attr_accessor :num_points

      # An array of length num_parts. Stores, for each ring, the index of its
      # first point in the points array. Array indexes are with respect to 0.
      attr_accessor :parts

      # An array of length num_points. The points for each ring in the polygon
      # are stored end to end. The points for Ring 2 follow the points for Ring
      # 1, and so on. The parts array holds the array index of the starting
      # point for each ring. There is no delimiter in the points array between
      # rings.
      attr_accessor :points

      def initialize
        @parts = []
        @points = []
      end

      def add_part(part)
        @parts << part
      end

      def add_point(point)
        @points << point
      end

    end
  end
end


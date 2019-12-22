# Class representing visual representation of edge
class VisualEdge
  # Starting +VisualVertex+ of this visual edge
  attr_accessor :v1
  # Target +VisualVertex+ of this visual edge
  attr_accessor :v2
  # Corresponding edge in the graph
  attr_reader :edge
  # Boolean value given directness
  attr_reader :directed
  # Boolean value emphasize character - drawn differently on output (TODO)
  attr_reader :emphesized
  # Weight of edge
  attr_reader :weight

  # create instance of +self+ by simple storing of all parameters
  def initialize(edge, v1, v2)
  	@edge = edge
    @v1 = v1
    @v2 = v2
    @weight = distance([v1.lat.to_f, v1.lon.to_f],[v2.lat.to_f, v2.lon.to_f])
  end

  # Calculate distance
  def distance(loc1, loc2)
    rad_per_deg = Math::PI / 180 # PI / 180
    rkm = 6371 # Earth radius in kilometers
    rm = rkm * 1000 # Radius in meters

    dlat_rad = (loc2[0] - loc1[0]) * rad_per_deg # Delta, converted to rad
    dlon_rad = (loc2[1] - loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map { |i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map { |i| i * rad_per_deg }

    a = Math.sin(dlat_rad / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad / 2) ** 2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))

    rm * c # Delta in meters
  end
end


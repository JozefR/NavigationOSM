require_relative '../process_logger'
require 'nokogiri'
require_relative 'graph'
require_relative 'visual_graph'

# Class to load graph from various formats. Actually implemented is Graphviz formats. Future is OSM format.
class GraphLoader
	attr_reader :highway_attributes

	# Create an instance, save +filename+ and preset highway attributes
	def initialize(filename, highway_attributes)
		@filename = filename
		@highway_attributes = highway_attributes 
	end

	# Load graph from Graphviz file which was previously constructed from this application, i.e. contains necessary data.
	# File needs to contain 
	# => 1) For node its 'id', 'pos' (containing its re-computed position on graphviz space) and 'comment' containig string with comma separated lat and lon
	# => 2) Edge (instead of source and target nodes) might contains info about 'speed' and 'one_way'
	# => 3) Generaly, graph contains parametr 'bb' containing array withhou bounds of map as minlon, minlat, maxlon, maxlat
	#
	# @return [+Graph+, +VisualGraph+]
	def load_graph_viz()
		ProcessLogger.log("Loading graph from GraphViz file #{@filename}.")
		gv = GraphViz.parse(@filename)

		# aux data structures
		hash_of_vertices = {}
		list_of_edges = []
		hash_of_visual_vertices = {}
		list_of_visual_edges = []		

		# process vertices
		ProcessLogger.log("Processing vertices")
		gv.node_count.times { |node_index|
			node = gv.get_node_at_index(node_index)
			vid = node.id

			v = Vertex.new(vid) unless hash_of_vertices.has_key?(vid)
			ProcessLogger.log("\t Vertex #{vid} loaded")
			hash_of_vertices[vid] = v

			geo_pos = node["comment"].to_s.delete("\"").split(",")
			pos = node["pos"].to_s.delete("\"").split(",")	
			hash_of_visual_vertices[vid] = VisualVertex.new(vid, v, geo_pos[0], geo_pos[1], pos[1], pos[0])
			ProcessLogger.log("\t Visual vertex #{vid} in ")
		}

		# process edges
		gv.edge_count.times { |edge_index|
			link = gv.get_edge_at_index(edge_index)
			vid_from = link.node_one.delete("\"")
			vid_to = link.node_two.delete("\"")
			speed = 50
			one_way = false
			link.each_attribute { |k,v|
				speed = v if k == "speed"
				one_way = true if k == "oneway"
			}
			e = Edge.new(vid_from, vid_to, speed, one_way)
			list_of_edges << e
			list_of_visual_edges << VisualEdge.new(e, hash_of_visual_vertices[vid_from], hash_of_visual_vertices[vid_to])
		}

		# Create Graph instance
		g = Graph.new(hash_of_vertices, list_of_edges)

		# Create VisualGraph instance
		bounds = {}
		bounds[:minlon], bounds[:minlat], bounds[:maxlon], bounds[:maxlat] = gv["bb"].to_s.delete("\"").split(",")
		vg = VisualGraph.new(g, hash_of_visual_vertices, list_of_visual_edges, bounds)

		return g, vg
	end

	# Method to load graph from OSM file and create +Graph+ and +VisualGraph+ instances from +self.filename+
	#
	# @return [+Graph+, +VisualGraph+]
	def load_graph()
		# Load osm file
		gv = Nokogiri::XML(File.open(@filename))

		# edges from way
		hash_of_edges_for_process = {}

		ways = gv.xpath("//way")

		# load edges from way to filter only those nodes that we need for process later
		# when we are going to create vertices and edges
		ways.length.times do |way_index|
			nd = ways[way_index].css('nd')
			# we need only those ways with highway atrr
			highway = ways[way_index].css("tag[k='highway']")[0]

			if highway != nil
				v_access = highway["v"]
				# if the type of highway is specified in highway attributes.
				if @highway_attributes.include?(v_access)
					(nd.length - 1).times do |nd_index|
						vid_from = nd[nd_index]["ref"]
						vid_to = nd[nd_index + 1]["ref"]

						if !hash_of_edges_for_process.has_key?(vid_from)
							hash_of_edges_for_process[vid_from] = vid_from
						end

						if !hash_of_edges_for_process.has_key?(vid_to)
							hash_of_edges_for_process[vid_to] = vid_to
						end
					end
				end
			end
		end

		hash_of_vertices = {}
		hash_of_visual_vertices = {}

		# process vertices
		ProcessLogger.log("Processing vertices")
		nodes = gv.xpath("//node")

		nodes.length.times do |node_index|
			node = nodes[node_index]
			vid = node["id"]

			# if the node is in the way
			if hash_of_edges_for_process.has_key?(vid)
				lat = node["lat"].to_f
				lon = node["lon"].to_f

				v = Vertex.new(vid) unless hash_of_vertices.has_key?(vid)
				ProcessLogger.log("\t Vertex #{vid} loaded")
				hash_of_vertices[vid] = v
				hash_of_visual_vertices[vid] = VisualVertex.new(vid, v, lat, lon, lat, lon)
				ProcessLogger.log("\t Visual vertex #{vid} in ")
			end
		end

		list_of_edges = []
		list_of_visual_edges = []

		# process edges
		ways.length.times do |way_index|
			nd = ways[way_index].css('nd')
			highway = ways[way_index].css("tag[k='highway']")[0]

			if highway != nil
				v_access = highway["v"]
				if @highway_attributes.include?(v_access)
					(nd.length - 1).times do |nd_index|
						vid_from = nd[nd_index]["ref"]
						vid_to = nd[nd_index + 1]["ref"]

						maxSpeedTag = ways[way_index].css("tag[k='maxspeed']")[0]
						maxSpeed = 50
						# if there is no stored value for max speed set default
						if maxSpeedTag != nil
							maxSpeed = maxSpeedTag["v"]
						end

						# if the way is oneway store true otherwise false
						oneWayTag = ways[way_index].css("tag[k='oneway']")[0]
						oneWay = false

						if oneWayTag != nil
							oneWayValue = oneWayTag["v"]
							if oneWayValue == "yes"
								oneWay = true
							end
						end

						e = Edge.new(vid_from, vid_to, maxSpeed, oneWay)
						list_of_edges << e
						list_of_visual_edges << VisualEdge.new(e, hash_of_visual_vertices[vid_from], hash_of_visual_vertices[vid_to])
					end
				end
			end
		end

		# Create instances of Graph and VisualGraph
		g = Graph.new(hash_of_vertices, list_of_edges)

		bounds = {}
		boundsXml = gv.xpath("//bounds")
		bounds[:minlon] = boundsXml[0]["minlon"]
		bounds[:minlat] = boundsXml[0]["minlat"]
		bounds[:maxlon] = boundsXml[0]["maxlon"]
		bounds[:maxlat] = boundsXml[0]["maxlat"]

		vg = VisualGraph.new(g, hash_of_visual_vertices, list_of_visual_edges, bounds)

		return g, vg
	end

end

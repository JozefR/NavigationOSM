require 'ruby-graphviz'
require_relative 'visual_edge'
require_relative 'visual_vertex'

# Visual graph storing representation of graph for plotting.
class VisualGraph
  # Instances of +VisualVertex+ classes
  attr_reader :visual_vertices
  # Instances of +VisualEdge+ classes
  attr_reader :visual_edges
  # Corresponding +Graph+ Class
  attr_reader :graph
  # Scale for printing to output needed for GraphViz
  attr_reader :scale

  # Create instance of +self+ by simple storing of all given parameters.
  def initialize(graph, visual_vertices, visual_edges, bounds)
  	@graph = graph
    @visual_vertices = visual_vertices
    @visual_edges = visual_edges
    @bounds = bounds
    @scale = ([bounds[:maxlon].to_f - bounds[:minlon].to_f, bounds[:maxlat].to_f - bounds[:minlat].to_f].min).abs / 10.0
  end

  # Export +self+ into Graphviz file given by +export_filename+.
  def export_graphviz(export_filename)
    # create GraphViz object from ruby-graphviz package
    graph_viz_output = GraphViz.new( :G, 
    								                  use: :neato, 
		                                  truecolor: true,
                              		    inputscale: @scale,
                              		    margin: 0,
                              		    bb: "#{@bounds[:minlon]},#{@bounds[:minlat]},
                                  		    #{@bounds[:maxlon]},#{@bounds[:maxlat]}",
                              		    outputorder: :nodesfirst)

    # append all vertices
    @visual_vertices.each { |k,v|
      graph_viz_output.add_nodes( v.id , :shape => 'point',
                                  :comment => "#{v.lat},#{v.lon}!!",
                                  :pos => "#{v.y},#{v.x}!")
    }

    # append all edges
    @visual_edges.each { |edge|
      graph_viz_output.add_edges( edge.v1.id, edge.v2.id, 'arrowhead' => 'none' )
    }

    # export to a given format
    format_sym = export_filename.slice(export_filename.rindex('.')+1,export_filename.size).to_sym
    graph_viz_output.output( format_sym => export_filename )
  end

  # Export +self+ into Graphviz file given by +export_filename+.
  def export_graphviz(export_filename, id_start, id_end)
    # create GraphViz object from ruby-graphviz package
    graph_viz_output = GraphViz.new( :G,
                                     use: :neato,
                                     truecolor: true,
                                     inputscale: @scale,
                                     margin: 0,
                                     bb: "#{@bounds[:minlon]},#{@bounds[:minlat]},
                                  		    #{@bounds[:maxlon]},#{@bounds[:maxlat]}",
                                     outputorder: :nodesfirst)

    if id_start != nil && id_end != nil
      # append all vertices
      @visual_vertices.each { |k,v|
        if (id_start == k || id_end == k)
          graph_viz_output.add_nodes( v.id ,
                                      :shape => 'point',
                                      :color => 'red',
                                      :width => '0.2',
                                      :comment => "#{v.lat},#{v.lon}!!",
                                      :pos => "#{v.y},#{v.x}!")
        else
          graph_viz_output.add_nodes( v.id ,
                                      :shape => 'point',
                                      :comment => "#{v.lat},#{v.lon}!!",
                                      :pos => "#{v.y},#{v.x}!")
        end
      }
    else
      # append all vertices
      @visual_vertices.each { |k,v|
        graph_viz_output.add_nodes( v.id , :shape => 'point',
                                    :comment => "#{v.lat},#{v.lon}!!",
                                    :pos => "#{v.y},#{v.x}!")
      }
    end

    # append all edges
    @visual_edges.each { |edge|
      graph_viz_output.add_edges( edge.v1.id, edge.v2.id, 'arrowhead' => 'none' )
    }

    # export to a given format
    format_sym = export_filename.slice(export_filename.rindex('.')+1,export_filename.size).to_sym
    graph_viz_output.output( format_sym => export_filename )
  end

  # Export +self+ into Graphviz file given by +export_filename+.
  def export_graphviz(export_filename, lat_start, lon_start, lat_end, lon_end)
    # create GraphViz object from ruby-graphviz package
    graph_viz_output = GraphViz.new( :G,
                                     use: :neato,
                                     truecolor: true,
                                     inputscale: @scale,
                                     margin: 0,
                                     bb: "#{@bounds[:minlon]},#{@bounds[:minlat]},
                                  		    #{@bounds[:maxlon]},#{@bounds[:maxlat]}",
                                     outputorder: :nodesfirst)

    # append all vertices
    @visual_vertices.each { |k,v|
      graph_viz_output.add_nodes( v.id , :shape => 'point',
                                  :comment => "#{v.lat},#{v.lon}!!",
                                  :pos => "#{v.y},#{v.x}!")
    }

    # append all vertices
    visual_edges.each { |edge|
      latStart = lat_start.to_f
      lonStart = lon_start.to_f
      latEnd = lat_end.to_f
      lonEnd = lon_end.to_f

      test1 = edge.v1.lat
      test2 = edge.v1.lon
      # 50.0865517
      # 14.4625145
      if ((lat_start.to_f == edge.v1.lat and lonStart == edge.v1.lon) or (latEnd == edge.v2.lat and lonEnd == edge.v2.lon))
        graph_viz_output.add_edges( edge.v1.id, edge.v2.id, 'arrowhead' => 'none', 'color' => 'red', 'penwidth' => '4' )
      else
        graph_viz_output.add_edges( edge.v1.id, edge.v2.id, 'arrowhead' => 'none')
      end
    }

    # export to a given format
    format_sym = export_filename.slice(export_filename.rindex('.')+1,export_filename.size).to_sym
    graph_viz_output.output( format_sym => export_filename )
  end

  def print_nodes()
    nodes = @visual_vertices

    nodes.each do |key, value|
      id = value.id
      lat = value.lat
      lon = value.lon

      p String(id) + ": " + String(lat) + ", " + String(lon)
    end
  end
end

require_relative 'visual_graph'

class ShortestPath

  def get_path(graph, visualGraph, latStart, lonStart, latEnd, lonEnd)

    # help dictionary with key vertice and edge value
    dic = {}

    # initialize helper data structures
    graph.vertices.each do |key|
      dic[key[0]] = []
    end

    visualGraph.visual_edges.each do |value|
      dic[value.v1.id].push(value.v2)
      dic[value.v2.id].push(value.v1)
    end

    min_heap = []

    # set start vertice for zero
    visualGraph.visual_edges.each do |edge|

      if (edge.v1.lat == latStart and edge.v1.lon == lonStart)
        edge.v2.pathValue = 0
        min_heap.push(edge)
        next
      end

      min_heap.push(edge)
    end

    while min_heap.length > 0
      currentVertex = min_heap.first
      min_heap.remove(currentVertex)


    end

    test = 123
  end


end

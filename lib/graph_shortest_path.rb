require_relative 'visual_graph'

class ShortestPath

  def get_path(graph, visualGraph, latStart, lonStart, latEnd, lonEnd)

    # help dictionary with key vertice and edge value
    dic = {}

    # initialize helper data structures
    visualGraph.visual_edges.each do |key|
      if !dic.key?(key.v1)
        dic[key.v1.id] = []
        dic[key.v2.id] = []
      end
    end

    visualGraph.visual_edges.each do |value|
        dic[value.v1.id].push(value)
    end

    min_heap = []

    # set start vertice path to zero
    dic.each do |key, value|
      found = false
      value.each do |val|
        if (val.v1.lat == latStart and val.v1.lon == lonStart)
          val.v1.pathValue = 0
          found = true
          min_heap.push([key, value])
          next
        end
      end
      if (found == false)
        min_heap.push([key, value])
      end
    end

    lastVertex = nil
    while min_heap.length > 0
      currentVertex = min_heap.first
      min_heap.delete_at(0)

      currentVertex[1].each do |edge|

        currentVerPathValue = edge.v1.pathValue
        edgeWeight = edge.weight
        edgeToPathValue = edge.v2.pathValue

        if currentVerPathValue + edgeWeight < edgeToPathValue
          edge.v2.pathValue = currentVerPathValue + edgeWeight
          edge.v2.parentVertex = edge
          lastVertex = edge

          cnt = 0
          found = false
          min_heap.each do |heapEdge|
            if heapEdge[0] == edge.v2.id
              priorityQueue = min_heap[cnt]
              min_heap.delete_at(cnt)
              min_heap.insert(0, priorityQueue)
              found = true
            end
            cnt += 1
          end

          cnt2 = 0
          if found == false
            min_heap.each do |heapEdge|
              test = heapEdge[1]
              test.each do |v|
                if v.v2.id == edge.v2.id
                  priorityQueue = min_heap[cnt2]
                  min_heap.delete_at(cnt2)
                  min_heap.insert(0, priorityQueue)
                end
              end
              cnt2 += 1
            end
          end

        end
      end
    end

    return graph, visualGraph
  end
end

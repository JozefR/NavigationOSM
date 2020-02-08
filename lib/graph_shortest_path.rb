require_relative 'visual_graph'

class ShortestPath

  def get_path(graph, visualGraph, latStart, lonStart, latEnd, lonEnd)

    # help dictionary with key vertice and edge value
    dic = {}
    startId = ""
    endId = ""

    # initialize helper data structures
    visualGraph.visual_edges.each do |key|
      if key != nil
        if dic[key.v1.id] == nil
          dic[key.v1.id] = []
        end
        if dic[key.v2.id] == nil
          dic[key.v2.id] = []
        end
        dic[key.v1.id] << key.v2
        dic[key.v2.id] << key.v1

        if (key.v1.lat == latStart and key.v1.lon == lonStart)
          key.v1.pathValue = 0
          startId = key.v1.id
        end

        if (key.v2.lat == latStart and key.v2.lon == lonStart)
          key.v2.pathValue = 0
          startId = key.v2.id
        end

        if (key.v1.lat == latEnd and key.v1.lon == lonEnd)
          endId = key.v1.id
        end

        if (key.v2.lat == latEnd and key.v2.lon == lonEnd)
          endId = key.v2.id
        end
      end
    end

    # A ← graf.vrcholy
    needToVisit = graph.vertices.map {|k,v| k};
    # Graf vrcholy
    vertexes = {}
    graph.vertices.each { |key, value|
      vertexes[key] = 999999;
    }
    # start path
    vertexes[startId] = 0;
    s = {}
    path = []
    while needToVisit.length > 0
      # m ← min(A.seber { |v| d[v] })
      minimum = needToVisit.map { |v| vertexes[v] }.min
      # N ← A.vyber { |v| d[v] == m }
      n = needToVisit.select {|v| vertexes[v] == minimum }[0];
      # A ← A – N
      needToVisit.delete(n);
      # for {u, v} in (N × A) ∩ graf.hrany
      dic[n].each do |neighbour|
        currentWeight = 0

        # d[v] ← min(d[v], d[u] + w({u, v}))
        visualGraph.visual_edges.each do |edge|
          if (edge.v1.id == n && edge.v2.id == neighbour.id || edge.v1.id == neighbour.id && edge.v2.id == n)
            currentWeight = vertexes[n] + edge.weight
            break
          end
        end

        if currentWeight < vertexes[neighbour.id]
          vertexes[neighbour.id] = currentWeight
          s[neighbour.id] = n;
        end
      end
    end

    u = endId
    s.each do |key, value|
      if key = u
        path.insert(0, u)
        u = s[u]
      end
    end
    path.insert(0, endId)

    return path
  end
end

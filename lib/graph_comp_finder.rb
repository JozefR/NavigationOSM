require_relative 'visual_graph'

class ComponentFinder

  def get_comp(graph, visualGraph)

    components = []
    visited = {}
    dic = {}

    graph.vertices.each do |key|
      visited[key[0]] = false
      dic[key[0]] = []
    end

    graph.edges.each do |value|
      dic[value.v1].push(value.v2)
      dic[value.v2].push(value.v1)
    end

    count = 0
    dic.each do |key, value|
      if (!visited[key])
        count_components(dic, key, visited, components)
        count += 1
      end
    end

    components.sort_by { |hsh| hsh[:zip] }
    components.shift

    components.each do |hash_to_delete|
      hash_to_delete.each do |key|

        graph.vertices.delete(key[0])
        visualGraph.visual_vertices.delete(key[0])

        graph.edges.length.times do |i|
          edge = graph.edges[i]
          if (edge != nil )
            if (edge.v1 != nil && edge.v2 != nil)
              if (edge.v1 == key[0] || edge.v2 == key[0])
                graph.edges.delete(edge)
              end
            end
          end

          visual_edge = visualGraph.visual_edges[i]
          if (visual_edge != nil )
            if (visual_edge.v1 != nil && visual_edge.v2 != nil)
              if (visual_edge.v1.id == key[0] || visual_edge.v2.id == key[0])
                visualGraph.visual_edges.delete(visual_edge)
              end
            end
          end
        end
      end
    end

    return graph, visualGraph
  end

  def count_components(hash, current, visited, components)
    if (visited[current[0]])
      return
    end

    stack = []

    hash[current].each do |value|
      stack << value
    end

    hash_of_vertices = {}

    while stack.length > 0
      vert = stack.pop

      if visited[vert] == false
        visited[vert] = true

        hash[vert].each do |value|
          stack << value

          hash_of_vertices[vert] = vert
        end
      end
    end

    components.push(hash_of_vertices)
  end
end

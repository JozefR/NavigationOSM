require_relative 'lib/graph_loader';
require_relative 'lib/graph_comp_finder';
require_relative 'lib/graph_shortest_path';
require_relative 'process_logger';

# osm_simple_nav.rb --load-comp data/old_town.osm --show-nodes
# osm_simple_nav.rb --load-comp data/near_ucl.osm --show-nodes 304321909 3509790192 data/test.pdf

# ruby osm2graphviz.rb --load-comp data/near_ucl.osm --show-nodes 50.087472, 14.4639902 50.0863163, 14.4591082 data/test.pdf
# ruby osm2graphviz.rb --load-comp data/near_ucl.osm --midist 50.087472, 14.4639902 50.0863163, 14.4591082 data/test.pdf
# ruby osm2graphviz.rb --load-comp data/near_ucl.osm --midist 50.0894357 14.4548421 50.0888219 14.4608849 data/test.pdf
# ruby osm2graphviz.rb --load-comp data/old_town.osm --midist 50.0861841 14.4344994 50.0917873 14.4346657 data/test.pdf

#  50.0894357 14.4548421 50.0888219 14.4608849

# Class representing simple navigation based on OpenStreetMap project
class OSM2graphviz

  # Creates an instance of navigation. No input file is specified in this moment.
  def initialize
    # register
    @load_cmds_list = ['--load-comp', ]
    @actions_list = ['--midist', '--show-nodes']

    @usage_text = <<-END.gsub(/^ {6}/, '')
	  	Usage:\truby osm_simple_nav.rb <load_command> <input.IN> <action_command> <output.OUT> 
	  	\tLoad commands: 
	  	\t\t --load ... load map from file <input.IN>, IN can be ['DOT']
	  	\tAction commands: 
	  	\t\t --export ... export graph into file <output.OUT>, OUT can be ['PDF','PNG','DOT']
    END
  end

  # Prints text specifying its usage
  def usage
    puts @usage_text
  end

  # Command line handling
  def process_args
    # not enough parameters - at least load command, input file and action command must be given
    if ARGV.length < 4
      puts "Not enough parameters!"
      puts usage
      exit 1
    end

    # read load command, input file and action command
    @load_cmd = ARGV.shift
    unless @load_cmds_list.include?(@load_cmd)
      puts "Load command not registred!"
      puts usage
      exit 1
    end

    @map_file = ARGV.shift
    unless File.file?(@map_file)
      puts "File #{@map_file} does not exist!"
      puts usage
      exit 1
    end

    @operation = ARGV.shift
    unless @actions_list.include?(@operation)
      puts "Action command not registred!"
      puts usage
      exit 1
    end

    @lat_start = ARGV.shift.to_f
    @lon_start = ARGV.shift.to_f
    @lat_end = ARGV.shift.to_f
    @lon_end = ARGV.shift.to_f

    # load output file
    @out_file = ARGV.shift
  end

  # Determine type of file given by +file_name+ as suffix.
  #
  # @return [String]
  def file_type(file_name)
    return file_name[file_name.rindex(".")+1,file_name.size]
  end

  # Specify log name to be used to log processing information.
  def prepare_log
    ProcessLogger.construct('log/logfile.log')
  end

  # Load graph from OSM file. This methods loads graph and create +Graph+ as well as +VisualGraph+ instances.
  def load_graph
    graph_loader = GraphLoader.new(@map_file, @highway_attributes)
    @graph, @visual_graph = graph_loader.load_graph()
  end

  # Load graph from Graphviz file. This methods loads graph and create +Graph+ as well as +VisualGraph+ instances.
  def import_graph
    graph_loader = GraphLoader.new(@map_file, @highway_attributes)
    @graph, @visual_graph = graph_loader.load_graph_viz
  end

  def load_comp
    comp_loader = ComponentFinder.new()
    @graph, @visual_graph = comp_loader.get_comp(@graph, @visual_graph)
  end

  def find_shortest_path
    shortest_path = ShortestPath.new()
    @path = shortest_path.get_path(@graph, @visual_graph, @lat_start, @lon_start, @lat_end, @lon_end)
  end

  def run
    # prepare log and read command line arguments
    prepare_log
    process_args

    # load graph - action depends on last suffix
    #@highway_attributes = ['residential', 'motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified']
    @highway_attributes = ['residential', 'motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'unclassified']
    #@highway_attributes = ['residential']
    if file_type(@map_file) == "osm" or file_type(@map_file) == "xml" then
      load_graph
    elsif file_type(@map_file) == "dot" or file_type(@map_file) == "gv" then
      import_graph
    else
      puts "Imput file type not recognized!"
      usage
    end

    if @load_cmd == '--load-comp'
      load_comp
    end

    # POZN: Zakreslení bodů proveďte vhodným způsobem, aby jej bylo možné dobře pozorovat
    # Program bude mít dále schopnost určit pro dvě zadaná místa nejkratší cestu,
    # pro níž také vypíše informaci o době, za jakou vozidlo cestu ujede (za použití maximální povolené rychlosti).
    # Navíc je úkolem tuto cestu zakreslit do mapy odlišnou barvou a tloušťkou čáry a tak zvýraznit její průběh ve výstupu.

    # Program bude mít následující rozhraní:

    # ruby osm2graphviz.rb --load-comp <input_map.IN> --midist 50.0865517 14.4625145 50.0898046 14.4611785 <exported_map.OUT>
    # Výstupem bude tedy mapa, na které budou jednotlivé úseky nejkratší cesty vhodně zvýrazněny - například barvou a tloušťkou čáry.

    # perform the operation
    case @operation
    when '--show-nodes'
        @visual_graph.export_graphviz_edges(@out_file, @lat_start, @lon_start, @lat_end, @lon_end)
    when '--midist'
        shortestPath = find_shortest_path
        @visual_graph.export_graphviz_path(@out_file, @lat_start, @lon_start, @lat_end, @lon_end, shortestPath)
        @visual_graph.print_nodes()
      return
    else
      usage
      exit 1
    end
  end
end

osm2graphviz = OSM2graphviz.new
osm2graphviz.run


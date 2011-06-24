require File.expand_path(File.join(File.dirname(__FILE__), "vsfile_reader.rb"))
require File.expand_path(File.join(File.dirname(__FILE__), "project.rb"))
require 'rubygems'
require 'graphviz'

class Cs_Sln_Graph
	# initialize the graph class
	def initialize(input, output, format)
		@input_path = input
		@output_path = output
		@format = format
		@graph = GraphViz.new("G")
		format_graph
	end

	# set up the default format for the graph
	def format_graph
		# set global node options
		@graph.node[:color]    = "#ddaa66"
		@graph.node[:style]    = "filled"
		@graph.node[:shape]    = "box"
		@graph.node[:penwidth] = "1"
		@graph.node[:fontname] = "Trebuchet MS"
		@graph.node[:fontsize] = "8"
		@graph.node[:fillcolor]= "#ffeecc"
		@graph.node[:fontcolor]= "#666666"
		@graph.node[:margin]   = "0.0"

		# set global edge options
		@graph.edge[:color]    = "#999999"
		@graph.edge[:weight]   = "1"
		@graph.edge[:fontsize] = "6"
		@graph.edge[:fontcolor]= "#444444"
		@graph.edge[:fontname] = "Verdana"
		@graph.edge[:dir]      = "forward"
		@graph.edge[:arrowsize]= "0.5"
	end
	
	# graph a solution file
	def graph_sln
		projects = VSFile_Reader.read_sln(@input_path)
		projects.each do |project|
			p_node = @graph.add_node(project.name)
			dependencies = VSFile_Reader.read_proj(project.path)
			dependencies.each do |dep|
				if dep.class == Project
					d_node = @graph.get_node(dep.name)
					if d_node.nil?
						d_node = @graph.add_node(dep.name)
					end
					@graph.add_edge(d_node, p_node)
				else
					if dep.start_with?("System.") || dep == "System"
						next
					end
					d_node = @graph.get_node(dep)
					if d_node.nil?
						d_node = @graph.add_node(dep)
						d_node[:color] = "#66ddaa"
						d_node[:fillcolor] = "#ccffee"
					end
					@graph.add_edge(d_node, p_node)
				end
			end
		end
		@graph.output(@format => @output_path)
	end
	
	# graph a project file
	def graph_proj
		projects = []
		projects << Project.new(nil, File.basename(@input_path, File.extname(@input_path)), @input_path)
		dependencies = VSFile_Reader.read_proj(@input_path)
		dependencies.each do |dep|
			if dep.class == Project
				projects << dep
			end
		end
		projects.each do |proj|
			p_node = @graph.add_node(proj.name)
			dependencies = VSFile_Reader.read_proj(proj.path)
			dependencies.each do |dep|
				if dep.class == Project
					d_node = @graph.get_node(dep.name)
					if d_node.nil?
						d_node = @graph.add_node(dep.name)
					end
					@graph.add_edge(d_node, p_node)
				else
					if not dep.start_with?("System")
						d_node = @graph.get_node(dep)
						if d_node.nil?
							d_node = @graph.add_node(dep)
							d_node[:color] = "#66ddaa"
							d_node[:fillcolor] = "#ccffee"
						end
						@graph.add_edge(d_node, p_node)
					end
				end
			end
		end
		@graph.output(@format => @output_path)
	end
end
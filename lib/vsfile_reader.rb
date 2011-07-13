require File.expand_path(File.join(File.dirname(__FILE__), "project.rb"))
require 'rexml/document'

class VSFile_Reader
	# get a list of projects from the solution file
	def self.read_sln(path)
		lines = []
		projects = []
		file = File.open(path) { |f| f.read }
		file.each_line do |line|
			match_data = line.match(/^\s*Project\s*\(\s*\"\{[A-F0-9\-]{36}\}\"\s*\)\s*=\s*\"(\S+)\"\s*,\s*\"(.*\.(vcproj|csproj))\"\s*,\s*\"\{([A-F0-9\-]{36})\}\"\s*$/i)
			if not match_data.nil?
				proj = Project.new(match_data[4], match_data[1], File.join(File.dirname(path), match_data[2]))
				projects << proj
			end
		end
		if projects.empty?
			raise "No projects found."
		end
		return projects
	end
	
	# get a list of dependencies for the given project
	def self.read_proj(path)
		dependencies = []
		begin
			file = File.open(path) { |f| f.read }
		rescue
			return dependencies
		end
		document = REXML::Document.new(file)
		# find external dependencies
		document.elements.each('//Project/ItemGroup/Reference') do |element|
			include = element.attributes["Include"]
			items = include.split(',')
			dependencies << items[0]
		end
		# find project dependencies
		document.elements.each('//Project/ItemGroup/ProjectReference') do |element|
			dep_path = File.absolute_path(File.join(File.dirname(path), element.attributes["Include"]))
			name = ""
			element.elements.each('Name') do |e|
				name = e.text
			end
			id = ""
			element.elements.each('Project') do |e|
				id = e.text
			end
			proj = Project.new(id, name, dep_path)
			dependencies << proj
		end
		return dependencies
	end
end
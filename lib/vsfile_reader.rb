require File.expand_path(File.join(File.dirname(__FILE__), "project.rb"))
require 'rexml/document'

class VSFile_Reader
	def self.read_sln(path)
		lines = []
		projects = []
		file = File.open(path) { |f| f.read }
		file.each_line do |line|
			match_data = line.match(/^\s*Project\s*\(\s*\"\{[A-F0-9\-]{36}\}\"\s*\)\s*=\s*\"(\S+)\"\s*,\s*\"(.*\.(vcproj|csproj))\"\s*,\s*\"\{([A-F0-9\-]{36})\}\"\s*$/i)
			if not match_data.nil?
				proj = Project.new(match_data[4], match_data[1], match_data[2])
				projects << proj
			end
		end
		if projects.empty?
			raise "No projects found."
		end
		return projects
	end
	
	def self.read_proj(path)
		dependencies = []
		file = File.open(path) { |f| f.read }
		document = REXML::Document.new(file)
		# find external dependencies
		document.elements.each('//Project/ItemGroup/Reference') do |element|
			include = element.attributes["Include"]
			items = include.split(',')
			dependencies << items[0]
		end
		# find project dependencies
		document.elements.each('//Project/ItemGroup/ProjectReference') do |element|
			path = element.attributes["Include"]
			name = ""
			element.elements.each('Name') do |e|
				name = e.text
			end
			id = ""
			element.elements.each('Project') do |e|
				id = e.text
			end
			proj = Project.new(id, name, path)
			dependencies << proj
		end
		return dependencies
	end
end
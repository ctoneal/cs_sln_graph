class Project
	attr_reader :id, :name, :path
	
	def initialize(id, name, path)
		@id = id
		@name = name
		@path = path
	end
end
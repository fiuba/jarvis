
class UnzipCommand < Command

	attr_accessor :target_dir
	attr_accessor :zip_file_name

	def self.forFileNamed(file_named)
		command = UnzipCommand.new
		command.zip_file_name = file_named 
		command
	end

	def execute( actions_set= {} )
		self.statement = "unzip -o #{zip_file_name}"
		if (!self.target_dir.nil?)
			self.statement += " -d #{self.target_dir}"
		end
		super( actions_set )
	end

end


class UnzipCommand < Command

	attr_accessor :target_dir
	attr_accessor :zip_file_name

	def self.forFileNamed(file_named)
		command = UnzipCommand.new
		command.zip_file_name = file_named 
		command
	end

	def execute 
		self.statement = "unzip -o #{zip_file_name}"
		if (!self.target_dir.nil?)
			self.statement += " -d #{self.target_dir}"
		end
		super
	end

end

=begin
How to use it

cmd = Command.with_statement('bash ./script_ok.sh')
cmd_result = cmd.execute
puts "Command result: #{cmd_result}"
puts "Command output: #{cmd.output}"

=end
class Command

	attr_accessor :statement
	attr_reader :output

	def self.with_statement(a_statement)
		command = Command.new
		command.statement = a_statement
		command
	end

	def execute 
		puts "about executing: #{statement}"
		@output = `#{statement}`
		$?.success?
	end

end
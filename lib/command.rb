=begin
How to use it

cmd = Command.with_statement('bash ./script_ok.sh')
cmd_result = cmd.execute
puts "Command result: #{cmd_result}"
puts "Command output: #{cmd.output}"

=end
class Command

	attr_accessor :statement
	attr_accessor :output

	def self.with_statement(a_statement)
		command = Command.new
		command.statement = a_statement
		command
	end

	def execute( actions_set = {} )
		grab_action( actions_set, :before).call( "#{statement}" )

		@output = `#{statement}`
		result = $?.success?

		grab_action( actions_set, :after).call( "#{@output.gsub( /\n/, '.')}" )

		result
	end

  def default_action
    Proc.new { |m| puts m }
  end

  private
  def grab_action( actions_set, at )
		(actions_set[at] || default_action )
  end

end

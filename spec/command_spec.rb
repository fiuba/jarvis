require 'rspec'
require_relative './../lib/command.rb'

describe Command do

	describe 'execute' do

		it 'should return true when system call returns 0' do
			script_path = File.expand_path(File.dirname(__FILE__) + '/script_ok.sh')
			cmd = Command.with_statement("bash #{script_path}")
			cmd.execute.should be true
		end

		it 'should return false when system call returns 1' do
			script_path = File.expand_path(File.dirname(__FILE__) + '/script_fail.sh')
			cmd = Command.with_statement("bash #{script_path}")
			cmd.execute.should be false
		end

		it 'should capture output' do
			script_path = File.expand_path(File.dirname(__FILE__) + '/script_some_output.sh')
			cmd = Command.with_statement("bash #{script_path}")
			cmd.execute
			cmd.output.should eq "some_output\n"
		end

	end

end

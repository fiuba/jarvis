require_relative './command.rb'
require_relative './rest_command.rb'
require_relative './unzip_command.rb'
require_relative './dropbox_downloader_command.rb'
require 'json'
require 'securerandom'

class CorrectorApp

	attr_reader :is_idle

	def get_and_unzip_file(id, file_path, target_file_name)
		cmd = Command.with_statement("mkdir #{id}")
		cmd_result = cmd.execute

		# download solution file
		cmd = DropboxDownloadCommand.forFileAt(file_path)
		cmd_result = cmd.execute
		File.write("#{id}/#{target_file_name}.zip", cmd.output)

		cmd = UnzipCommand.forFileNamed("#{id}/#{target_file_name}.zip")
		cmd.target_dir = "#{id}"
		cmd_result = cmd.execute
	end

	def prepare_pharo_image(id)
		cmd = Command.with_statement("cp Pharo-2.image #{id}/Pharo-2.image")
		cmd_result = cmd.execute

		cmd = Command.with_statement("cp Pharo-2.changes #{id}/Pharo-2.changes")
		cmd_result = cmd.execute

		cmd = Command.with_statement("cp PharoV20.sources #{id}/PharoV20.sources")
		cmd_result = cmd.execute
	end

	def archive_files(id)
		archive_dir_name = "old-#{id}-#{SecureRandom.uuid}"
		cmd = Command.with_statement("mv #{id} #{archive_dir_name}")
		cmd_result = cmd.execute
	end

	def report_result(id, result, output)
		url = "#{ENV['ALFRED_API_URL']}/task_result" 
		RestClient.post( url, 
		  {
		    :id => id,
		    :test_result => result,
		    :test_output => output} , { :api_key => ENV['ALFRED_API_KEY'] })
	end

	def execute_correction

		# get task details
		url = "#{ENV['ALFRED_API_URL']}/next_task"
		cmd = RestCommand.for_url(url)
		cmd_result = cmd.execute
		correction_data = JSON.parse cmd.output
		id = correction_data['id']
		
		get_and_unzip_file(id, correction_data['solution_file_path'], 'solution')
		get_and_unzip_file(id, correction_data['test_file_path'], 'test')
		
		# create test_script file
		File.write("#{id}/test_script.sh", correction_data['test_script'])		
		
		prepare_pharo_image(id)

		# execute the test
		cmd = Command.with_statement("cd #{id} \n bash test_script.sh")
		cmd_result = cmd.execute

		puts "Resultado: #{cmd_result}"
		puts cmd.output

		archive_files(id)

		report_result(id, cmd_result, cmd.output)

		puts "done"
	end

	def run
		run_loop
	end

	def run_loop
		is_idle = true
		loop do
			sleep 1
			if (is_idle)
				is_idle = false
				execute_correction
				is_idle = true
			end
		end
	end

end

CorrectorApp.new.run
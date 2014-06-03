require_relative './logger/logger.rb'
require_relative './command.rb'
require_relative './rest_command.rb'
require_relative './unzip_command.rb'
require_relative './dropbox_downloader_command.rb'
require 'json'
require 'securerandom'
require 'logger'

class CorrectorApp

	attr_reader :is_idle

	def initialize
		@is_idle = false
		@logger = Jarvis.logger
	end

  def default_actions_set
    { 
      :before => Proc.new { |m| @logger.info "running: #{m}" },
      :after  => Proc.new { |m| @logger.info "result: #{m}" } 
    }
  end

	def get_and_unzip_file(id, file_path, target_file_name)
		cmd = Command.with_statement("mkdir -p #{id}")
		cmd_result = cmd.execute( default_actions_set )

		@logger.info 'About downloading file'
		@logger.debug "Dropbox token: #{ENV['DROPBOX_APP_KEY']}"
		# download solution file
		cmd = DropboxDownloadCommand.forFileAt(file_path)
		cmd_result = cmd.execute
		File.write("#{id}/#{target_file_name}.zip", cmd.output)
		@logger.info 'file downloaded'

		cmd = UnzipCommand.forFileNamed("#{id}/#{target_file_name}.zip")
		cmd.target_dir = "#{id}"
		cmd_result = cmd.execute( default_actions_set )
	end

	def prepare_pharo_image(id)
		cmd = Command.with_statement("cp Pharo-2.image #{id}/Pharo-2.image")
		cmd_result = cmd.execute( default_actions_set )

		cmd = Command.with_statement("cp Pharo-2.changes #{id}/Pharo-2.changes")
		cmd_result = cmd.execute( default_actions_set )

		#cmd = Command.with_statement("cp PharoV20.sources #{id}/PharoV20.sources")
		#cmd_result = cmd.execute
	end

	def archive_files(id)
		archive_dir_name = "old-#{id}-#{SecureRandom.uuid}"
		cmd = Command.with_statement("mv #{id} #{archive_dir_name}")
		cmd_result = cmd.execute( default_actions_set )
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

		@logger.info 'Checking for pending tasks.'
		task_result = 'undefined'
		task_output = 'Error while processing'


		# get task details
		url = "#{ENV['ALFRED_API_URL']}/next_task"
		cmd = RestCommand.for_url(url)
		cmd_result = cmd.execute
		correction_data = JSON.parse cmd.output
		
		if correction_data.empty?
			@logger.info 'No pending tasks found.'
			@is_idle = true
			return
		end

		@is_idle = false

		id = correction_data['id']

		begin		
			get_and_unzip_file(id, correction_data['solution_file_path'], 'solution')
			get_and_unzip_file(id, correction_data['test_file_path'], 'test')
			
			test_script_data = correction_data['test_script']
			test_script_data = test_script_data.gsub("\r\n","\n")
			# create test_script file
			f = File.new("#{id}/test_script.sh", "w+b")		
			f.write(test_script_data)
      f.close()
			
			prepare_pharo_image(id)

			# execute the test
			cmd = Command.with_statement("cd #{id} \n bash test_script.sh")
			task_result = cmd.execute ? 'passed' : 'failed'
			task_output = cmd.output
			puts task_result

			@logger.debug "Task executed, result:#{task_result}, output: #{cmd.output}"
			@logger.info "Task executed, result:#{task_result}."
		rescue
			task_output = $!
			@logger.error "Task proccessing error:#{task_output}"
		ensure
			@logger.info 'Publishing task results.'
			report_result(id, task_result, task_output)
			@logger.info 'Archiving files.'
			#archive_files(id)
		end
	end

	def run
		#execute_correction
		run_loop
	end

	def run_loop
		@logger.info 'Starting working loop.'
		idle_counter = 0;
		while (idle_counter < 5) do
			sleep 1
			if (@is_idle)
				idle_counter+=1
			end
			begin
				@logger.info 'Task processing started.'
				execute_correction
				@logger.info 'Task successfully proccessed.'
			rescue 
				@logger.info "Task proccessing failed with errors: #{$!}\n"
			ensure
				@logger.info '-----------------------------'
				@logger.info ' '
			end
		end
		@logger.info 'Finishing working loop.'
    @logger.close
	end

end

CorrectorApp.new.run

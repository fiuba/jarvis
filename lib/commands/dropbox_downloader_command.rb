require 'dropbox_sdk'

class DropboxDownloadCommand < Command

	attr_accessor :file_path

  def self.forFileAt(file_path)
  	cmd = DropboxDownloadCommand.new
  	cmd.file_path = file_path
  	cmd
	end

	def execute
    session = DropboxSession.new(ENV['DROPBOX_APP_KEY'], ENV['DROPBOX_APP_SECRET'])
    session.set_request_token(ENV['DROPBOX_REQUEST_TOKEN_KEY'], ENV['DROPBOX_REQUEST_TOKEN_SECRET'])
    session.set_access_token(ENV['DROPBOX_AUTH_TOKEN_KEY'], ENV['DROPBOX_AUTH_TOKEN_SECRET'])
    client = DropboxClient.new(session, :app_folder)
		self.output = client.get_file(file_path)
		true
	end
end
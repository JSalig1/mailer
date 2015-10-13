require './listener'
require './mailer'
require './composer'
require './email_reader'
require './file_reader'
require 'dotenv'

Dotenv.load

class NotificationsController
  def run
    email_reader = EmailReader.new
    mailer = Mailer.new(email_reader)
    composer = Composer.new(mailer)
    file_reader = FileReader.new
    listener = Listener.new(composer, file_reader)
    listener.watch_folder
  end
end

notifications_controller = NotificationsController.new
notifications_controller.run

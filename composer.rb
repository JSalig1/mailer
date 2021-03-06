class Composer
  include Sidekiq::Worker

  def initialize
    email_reader = EmailReader.new
    mailer = Mailer.new(email_reader)
    file_reader = FileReader.new
    @mailer = mailer
    @file_reader = file_reader
    @last_message_sent
  end

  def perform(server_event)

    project_name, folder_and_file = extract_from(server_event)

    recipients = @file_reader.get_addresses_for(project_name)
    if recipients.any?
      write_email(project_name, folder_and_file, recipients)
    else
      puts "e-mail text file not present or empty"
    end
  end

  private

  def write_email(project_name, folder_and_file, recipients)
    emails = @mailer.fetch_emails
    user, file_list = match_notifications_by(folder_and_file, emails)
    if user && file_list
      delivery_size = file_list.pop
      message = "<div style='border: 3px solid #1E9FDB; border-radius: 5px; padding: 15px; background: #eeeeee;'><h1><center><font style='font-family: Impact, Charcoal, sans-serif; font-weight: lighter; color: #424242'>1stAveMachine Share</font><center></h1><b><center>#{user} has uploaded content to:</center></b><br/><h2><font color='#1E9FDB'><center><a target='_blank' href='1stavemachineshare.mediashuttle.com' style='text-decoration: none;'>#{project_name}</a></center></font></h2> <br/><b>The delivery contains:<b><br/><br/><div style='border: .7px dotted gray; padding: 5px; background: white;'>#{file_list.join("<br/>")}</div><br/>Total delivery size: #{delivery_size}<br/><center><a target='_blank' href='www.signiant.com/products/media-shuttle'><img src='https://ci3.googleusercontent.com/proxy/L9dwn2hjiQ-YiqWCBdbA5NtcPhVYsI41rjGMUT50ezqDbr8hXDkqTNEuQ1Hqi5tW5VCo92ZbouWsDC1KuhzbK2Sokc7OWWAe4YL1VusLgki5roZkbzXQ=s0-d-e1-ft#http://staticdata-b.mediashuttle.com/images/powered-by-sig-ms.png' style='width:181px;min-height:auto;border:none;align:right'></a></center></div>"
      if message == @last_message_sent
        puts "duplicate notification detected... aborting"
      else
        @last_message_sent = message
        puts "sending notifications for #{project_name}: #{recipients}"
        @mailer.send_notification(project_name, message, recipients)
        puts "Sent!"
        puts
        puts
      end
    end
  end

  def extract_from(server_event)
    path_parts = server_event.first.split("/")
    project_name = path_parts[1]
    folder_and_file = path_parts[-2..-1]
    return project_name, folder_and_file
  end

  def match_notifications_by(folder_and_file, emails)
    file = folder_and_file.last.gsub(/\s/, "")
    user, file_list = find_by(file, emails)
    if not user && file_list
      folder = folder_and_file.first.gsub(/\s/, "")
      user, file_list = find_by(folder, emails)
    end
    return user, file_list
  end

  def find_by(search_item, emails)
    match = 0
    user = nil
    file_list = nil
    emails.each do |key, value|
      #puts "checking for #{search_item} within #{key} with #{value}"
      if value.include?(search_item)
        user = key
        file_list = value
        match += 1
      end
    end
    puts "matched e-mails found: #{match}"
    puts
    if match == 1
      return user, file_list
    else
      return nil
    end
  end
end

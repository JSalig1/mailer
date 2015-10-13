require 'nokogiri'

class EmailReader
  def parse(emails)

    parsed_emails = {}

    emails.each do |mail|
      #puts "From #{mail.from}"
      #puts "Subject: #{mail.subject}:"
      #puts "Date: #{mail.date.to_s}"
      text = Nokogiri::HTML(mail.parts[0].body.decoded.gsub("</div>", ";")).text
      subtext = text.scan(/Share([^>]*)Privacy/).last.first
      subtext = subtext.gsub(/\s/, "").gsub(/;{2}/, "").gsub(/has.{,4}loaded.*content/, "").gsub(/Total.{8}size/, "").split(":")

      #puts subtext.inspect

      # the user
      user = subtext.first

      # An array containing file name items
      file_list = subtext[1].split(";").map{ |i| i.gsub(/...and/, "...and ").gsub("morefiles", " more files").gsub("morefile", " more file") }

      # delivery size as a string
      delivery_size = subtext[2]

      file_list << delivery_size

      parsed_emails.store(user, file_list)
      #puts "*************"
      #puts
    end
    return parsed_emails
  end
end

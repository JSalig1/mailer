require 'mail'

class Mailer

  def initialize(html_parser)

    @html_parser = html_parser

    Mail.defaults do
      retriever_method :imap, {
        address:    "imap.googlemail.com",
        port:       993,
        user_name:  ENV['USER_NAME'],
        password:   ENV['PASSWORD'],
        enable_ssl: true
      }
      delivery_method :smtp, {
        port:         587,
        address:      "smtp.gmail.com",
        user_name:    ENV['USER_NAME'],
        password:     ENV['PASSWORD'],
        authentication:    "plain",
        enable_starttls_auto:    true
      }
    end
  end

  def fetch_emails
    emails = Mail.find what: :last, count: 20, order: :asc,
      keys: ["FROM", "portals@mediashuttle.com", "SUBJECT", "1st Ave Machine Share"]
    @html_parser.parse(emails)
  end

  def send_notification(project_name, message, recipients)
    Mail.deliver do
      to      "#{recipients.join(', ')}"
      from    "1stAveMachine <do-not-reply@1stavemachine.com>" # Your from name and email address
      subject "Media Shuttle: Files added to #{project_name}"

      text_part do
        body "#{message}"
      end

      html_part do
        content_type 'text/html; charset=UTF-8'
        body "#{message}"
      end
    end
  end

end

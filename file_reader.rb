class FileReader

  def initialize
    @path = ENV['0_PROJECTS']
  end

  def get_addresses_for(project)
    file = @path + '/' + project + '/' + '0_notifications_email_list.txt'
    email_list = []
    if File.exist?(file)
      File.open(file).readlines.each do |line|
        email_list << line.chomp
      end
    end
    return email_list
  end

end

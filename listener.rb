require 'listen'

class Listener

  def initialize(composer, file_reader)
    @composer = composer
    @file_reader = file_reader
  end

  def watch_folder
    path = ENV['SERVER_PATH']
    listener = Listen.to(path) do |modified, added, removed|
      if modified.size > 0
        #puts "modified files detected:"
        #puts modified
        #sleep(5)
        #modified = validate(modified)
      end
      if added.size > 0
        puts
        puts "added files detected:" + added.join(", ")
        sleep(5)
        added = validate(added)
        if added.any?
          report(added, path)
        end
      end
      if removed.size > 0
        #puts "removed files detected:"
        #puts removed
        #sleep(5)
        #removed = validate(removed)
      end
    end

    listener.start
    puts "Watching #{path} for changes..."
    sleep
  end

  private

  def validate(event)
    puts "validating..."
    puts
    validated = []
    event.each do |file_path|
      if file_path.include?("#work_file#") or file_path.include?("#chkpt_file#")
        puts "work or chkpt file -- skipping..."
      else
        validated << file_path
      end
    end
    #puts "valid files: #{validated.inspect}"
    return validated
  end

  def report(server_event, path)
    puts "*******NEW FILE ADDED AT #{Time.now}*******"
    puts "file path: #{server_event}"
    sleep(7)
    puts "reporting..."
    path_parts = server_event.first.split("/")
    project_name = path_parts[3]
    folder_and_file = path_parts[-2..-1]
    recipients = @file_reader.get_addresses_for(path, project_name)
    if recipients.any?
      @composer.write_email(project_name, folder_and_file, recipients)
    else
      puts "e-mail text file not present or empty"
    end
  end

end
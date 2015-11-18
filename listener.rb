require 'listen'

class Listener

  def initialize(composer)
    @composer = composer
    @path = ENV['0_PROJECTS']
  end

  def watch_folder
    listener = Listen.to(@path) do |modified, added, removed|
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
          report(added)
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
    puts "Watching #{@path} for changes..."
    sleep
  end

  private

  def validate(event)
    puts "validating files..."
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

  def report(server_event)
    puts "*******NEW FILE ADDED AT #{Time.now}*******"
    puts "file path: #{server_event}"
    sleep(7)
    puts "reporting..."

    project_name, folder_and_file = extract_from(server_event)

    @composer.process(project_name, folder_and_file, @path)
  end

  def extract_from(server_event)
    path_parts = server_event.first.gsub(@path, "").split("/")
    project_name = path_parts[1]
    folder_and_file = path_parts[-2..-1]
    return project_name, folder_and_file
  end

end

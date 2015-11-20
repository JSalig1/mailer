require 'listen'

class Listener

  def initialize(composer)
    @composer = composer
    @path = ENV['0_PROJECTS']
  end

  def watch_folder
    listener = Listen.to(@path) do |modified, added, removed|
      if modified.size > 0
        log(modified, "modified")
      end
      if added.size > 0
        log(added, "added")
      end
      if removed.size > 0
        log(removed, "removed")
      end
    end

    listener.start
    puts "Watching #{@path} for changes..."
    sleep
  end

  private

  def log(server_event, action)
    server_event.reject!(&temp_files)
    if server_event.any?
      puts "\nfiles #{action}:"
      puts server_event
      if action == "added"
        report(server_event)
      end
    end
  end

  def report(server_event)
    puts "reporting..."
    server_event.each(&remove_path_info)
    @composer.process(server_event)
  end

  def remove_path_info
    Proc.new { |server_entry| server_entry.sub!(@path, "") }
  end

  def temp_files
    Proc.new { |server_entry| server_entry.include?("#work_file#") or server_entry.include?("#chkpt_file#") }
  end
end

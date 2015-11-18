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
        added.reject!(&temp_files)
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

  def report(server_event)
    puts "*******NEW FILE ADDED AT #{Time.now}*******"
    puts "file path: #{server_event}"
    sleep(7)
    puts "reporting..."
    server_event.each(&remove_path_info)
    @composer.process(server_event)
  end

  def remove_path_info
    Proc.new { |server_entry| server_entry.sub!(@path, "") }
  end

  def temp_files
    Proc.new { |file_path| file_path.include?("#work_file#") or file_path.include?("#chkpt_file#") }
  end
end

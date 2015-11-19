require 'listen'

class Listener

  def initialize(composer)
    @composer = composer
    @path = ENV['0_PROJECTS']
  end

  def watch_folder
    listener = Listen.to(@path) do |modified, added, removed|
      if modified.size > 0
        puts "files modified:"
        puts modified
      end
      if added.size > 0
        puts "files added:"
        puts added
        added.reject!(&temp_files)
        if added.any?
          report(added)
        end
      end
      if removed.size > 0
        puts "files removed:"
        puts removed
      end
    end

    listener.start
    puts "Watching #{@path} for changes..."
    sleep
  end

  private

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

class Command
	attr_accessor :description
	def to_s
		return @description
	end
end

class AddCommand < Command
	attr_accessor :tasks
	def initialize 
		@description = "Adds new task"
	end
	
	def run args
		task = Task.new
		task.name = args.join
		@tasks.add_task task
		puts "Added #{task.name}"
	end
end

class ShowCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "Show tasks"
	end
	
	def run args
		done = false
		marked = false
		all = false
		args.each do |arg|
			if arg == "done" then done = true
			elsif arg == "marked" then marked = true
			elsif arg == "all" then all = true
			else
				puts "Invalid option #{arg}"
				return
			end
		end
		@tasks.each do |task|
			if task.filter(all, done, marked) == true then
				task.show
			end
		end
	end
end

class DoneCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "Mark task as done"
	end
	
	def run args
		id = args[0].to_i
		task = @tasks.find_id id
		if !task then puts "No task id #{id} found"
		else task.done = true
		end
	end
end

class MarkCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "Mark task"
	end
	
	def run args
		id = args[0].to_i
		@tasks.each do |task|
			if task.id == id
				task.mark = true
			end
		end
	end
end

class SortCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "Sort tasks with filter"
	end
	
	def run args
		@tasks.sort!.reverse! {|a, b| a <=> b}
	end
end

class ResetCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "Reset task list"
	end
	
	def run args
		@tasks.clear
	end
end

class ExportCommand < Command
	attr_accessor :tasks, :format, :all, :done, :marked
	def initialize
		@description = "Exports task list"
	end
	
	def run args
		done = false
		marked = false
		all = false
		args.each do |arg|
			if arg == "done" then @done = true
			elsif arg == "marked" then @marked = true
			elsif arg == "all" then @all = true
			else
				puts "Invalid option #{arg}"
				return
			end
		end
		export_html
	end
	
	def export_html
		file = File.new("./export.html", "w")
		file.puts "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\""
		file.puts "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"
		file.puts "<head>"
		file.puts "<meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\" />"
		file.puts "</head>"
		file.puts "<html>"
		file.puts "<h1>Rubido task list</h1>"
		file.puts "<ul>"
		@tasks.each do |task|
			if task.filter(@all, @done, @marked) == true then
				file.puts "<li>"
				file.puts "#{task.id} #{task.created_at.hour}:#{task.created_at.min} #{task.created_at.day}.#{task.created_at.month} #{task.created_at.year}\t#{task.name}"
				file.puts "</li>"
			end
		end
		file.puts "</ul>"
		file.puts "</html>"
		
		file.close
		puts "Exported to 'export.html'"
	end
end


class HelpCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "Displays help"
	end
	
	def run args
		if !args[0]
			puts "Rubido - commandline task manager"
			puts "version #{@tasks.version}"
			puts "	[format] can be all, done, marked"
			puts "* add [task description]"
			puts "* show [filter]"
			puts "* done [id] - mark task as done"
			puts "* mark [id] - mark task"
			puts "* sort [filter] - sort all tasks"
			puts "* export [filter] [format] - export task list to export.format"
			puts "* help [option] for details"
		elsif args.size > 1
			puts "Wrong number of arguments"
		elsif args[0] == "add"
			puts "add command - add new task to list"
			puts "usage: add [options] [task description]"
			puts "options:"
			puts "* option1"
		else
			puts "Unknown command '#{args[0]}'."
		end
	end
end

class ExitCommand < Command
	def initialize
		@description = "Exit rubido"
	end
	
	def run args
		puts "Thank you for using rubido"
		Process.exit
	end
end

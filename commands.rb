class Command
	attr_accessor :description
end

class AddCommand < Command
	attr_accessor :tasks
	def initialize 
		@description = "add [description] - adds new task"
	end
	
	def success arg
		return "Added #{arg}"
	end
	
	def run args
		task = Task.new
		task.name = args.join
		if !task.name.empty? then
			@tasks.add_task task
			puts success( task.name )
		else puts "No description specified!"
		end
	end
end

class ShowCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "show [filter] - show tasks"
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
				puts task.show
			end
		end
	end
end

class DoneCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "done [id] - mark task as done"
	end
		
	def success arg
		return "Task #{arg} done"
	end
	
	def run args
		id = args[0].to_i
		task = @tasks.find_id id
		if !task then puts "No task id #{id} found"
		else 
			task.done = true
			puts success( id )
		end
	end
end

class MarkCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "mark [id] - mark task"
	end
	
	def success arg
		return "Task #{arg} marked"
	end
	
	def run args
		id = args[0].to_i
		task = @tasks.find_id id
		if !task then puts "No task id #{id} found"
		else 
			task.mark = true
			puts success( id )
		end
	end
end

class SortCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "sort - sort tasks with filter"
	end
	
	def success
		return "Task list sorted"
	end
	
	def run args
		@tasks.sort!.reverse! {|a, b| a <=> b}
		print success
	end
end

class ResetCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "reset - reset task list"
	end
	
	def success
		return "Task list resetted"
	end
	
	def run args
		@tasks.clear
		puts success
	end
end

class ClearCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "clear [filter] - removes all filtered tasks"
	end
	
	def success
		return "Task list cleared"
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
			if all || (marked && task.mark) || (done && task.done) || (!all && !marked && !done && task.done) then
				@tasks.delete(task)
				puts success
			end
		end
	end
end

class ExportCommand < Command
	attr_accessor :tasks, :format, :all, :done, :marked
	def initialize
		@description = "export [filter] [format] - exports task list"
	end
	
	def success
		return "Task list exported"
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
		puts success
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
				file.puts task.show
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
		@description = "help [command] - displays help"
	end
	
	def run args
		if !args[0]
			puts "Rubido - commandline task manager"
			puts "version #{@tasks.version}"
			puts "[format] can be all, done, marked"
			puts "* "+AddCommand.new.description
			puts "* "+ShowCommand.new.description
			puts "* "+DoneCommand.new.description
			puts "* "+MarkCommand.new.description
			puts "* "+ClearCommand.new.description
			puts "* "+ResetCommand.new.description
			puts "* "+SortCommand.new.description
			puts "* "+ExportCommand.new.description
			puts "* "+HelpCommand.new.description
		elsif args.size > 1
			puts "Wrong number of arguments"
		elsif args[0] == "add"
			puts AddCommand.new.to_s
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
		@description = "exit, quit - exit rubido"
	end
	
	def run args
		puts "Thank you for using rubido"
		Process.exit
	end
end

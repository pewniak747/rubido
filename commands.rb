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
		arg = args[0]
		if ![nil, "all", "done", "marked"].include? arg then
			puts "invalid argument"
			return
		end
		@tasks.each do |task|
			if((!arg && !task.done)|| arg == "all" || (arg == "done" && task.done) || (arg == "marked" && task.mark)) then
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
		@tasks.each do |task|
			if task.id == id
				task.done = true
			end
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

class ResetCommand < Command
	attr_accessor :tasks
	def initialize
		@description = "Reset task list"
	end
	
	def run args
		@tasks.clear
	end
end

class HelpCommand < Command
	def initialize
		@description = "Displays help"
	end
	
	def run args
		puts "Rubido - commandline task manager"
		puts "version #{@version}"
		puts "add [task description]"
		puts "show [all, done, marked]"
		puts "done [id] - mark task as done"
		puts "mark [id] - mark task"
		puts "help [option] for details"
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

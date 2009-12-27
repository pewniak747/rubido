# rubido - cmmandline task manager
# by Tomasz 'pewniak747' Pewiński
# pewniak747@gmail.com

require 'yaml'
require 'date'
require 'commands.rb'

class Rubido
	def initialize
		@version = 0
		load_file
		@commands = {}
		@commands["add"] = AddCommand.new
		@commands["add"].tasks = @tasks
		@commands["show"] = ShowCommand.new
		@commands["show"].tasks = @tasks
		@commands["done"] = DoneCommand.new
		@commands["done"].tasks = @tasks
		@commands["mark"] = MarkCommand.new
		@commands["mark"].tasks = @tasks
		@commands["reset"] = ResetCommand.new
		@commands["reset"].tasks = @tasks
		@commands["exit"] = ExitCommand.new
		@commands["help"] = HelpCommand.new
	end

	def parse input
		args = input.split
		command = args.first
		args.delete_at 0
		run_command = @commands[command]
		if !run_command then puts "unknown command'#{command}'"
		else 
			run_command.run args
		end
	end
	
	def start
		puts "Rubido - commandline task manager"
		print ": "
		while line = gets.chop do
			parse line
			print ": "
			save_file
		end
	end
	
	def save_file
		File.open("data.yml","w") do |file|
			YAML.dump(@tasks, file)
		end
	end
	
	def load_file
		File.open("data.yml","r") do |file|
			@tasks = YAML.load(file)
		end
		@tasks = TaskList.new if !@tasks
	end
end

class Task
	attr_accessor :name, :id, :created_at, :done, :mark
	def initialize
		@name = ""
		@done = false
		@mark = false
		@created_at = Time.now
	end
	
	def show
		print "#{self.id} #{self.created_at.hour}:#{self.created_at.min} #{self.created_at.day}.#{self.created_at.month} #{self.created_at.year}\t#{self.name}\n"
	end
end

class TaskList < Array
	def initialize
		@id_counter = 0
	end
	
	def get_id
		@id_counter = max_id if !@id_counter
		@id_counter += 1
	end
	
	def max_id
		max = 0
		self.each do |task|
			max = task.id if max < task.id
		end
		max
	end
	
	def add_task task
		task.id = get_id
		self << task
	end
end

app = Rubido.new
app.start

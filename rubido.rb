#!/usr/bin/ruby
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
		@commands["sort"] = SortCommand.new
		@commands["sort"].tasks = @tasks
		@commands["export"] = ExportCommand.new
		@commands["export"].tasks = @tasks
		@commands["reset"] = ResetCommand.new
		@commands["reset"].tasks = @tasks
		@commands["quit"] = ExitCommand.new
		@commands["exit"] = ExitCommand.new
		@commands["help"] = HelpCommand.new
		@commands["help"].tasks = @tasks
	end

	def parse input
		args = split input
		command = args.first
		args.delete_at 0
		run_command = @commands[command]
		if !run_command then puts "unknown command '#{command}'"
		else 
			run_command.run args
		end
	end
	
	def start
		puts "Rubido - commandline task manager"
		@commands["show"].run []
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
		@tasks.version = @version
	end
	
	def split input
		args = []
		temp = ""
		opened = false
		input.each_char do |char|
			if char == '"' then opened = !opened
			elsif char =~ /\s/ && opened then
				temp += char
			elsif char =~ /\s/ && !opened then
				args << temp
				temp = ""
			else
				temp.concat char
			end
		end
		args << temp if !temp.empty?
		return args
	end
end

class Task
	attr_accessor :name, :id, :created_at, :done, :mark
	include Comparable
	
	def initialize
		@name = ""
		@done = false
		@mark = false
		@created_at = Time.now
	end
	
	def filter all, done, marked
		if all || (marked && self.mark) || (done && self.done) || (!all && !marked && !done && !self.done) then
			return true
		else return false
		end
	end
	
	def show
		print "#{self.id} #{self.created_at.hour}:#{self.created_at.min} #{self.created_at.day}.#{self.created_at.month} #{self.created_at.year}\t#{self.name}\n"
	end
	
	def <=> other
		self.created_at <=> other.created_at
	end
end

class TaskList < Array
	attr_accessor :version
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
	
	def find_id id
		self.each do |task|
			if task.id == id
				return task
			end
		end
		return nil
	end
end

app = Rubido.new
app.start

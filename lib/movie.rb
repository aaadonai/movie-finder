require 'support/format_helper'
class Movie
	include FormatHelper

	@@filepath = nil

	def self.filepath=(path=nil)
		@@filepath = File.join(APP_ROOT,path)
	end

	attr_accessor :title,:genre,:length

	def self.file_exists?
		# class should know if the movie file exists
		if @@filepath && File.exists?(@@filepath)
			return true
		else
			return false	
		end
	end

	def self.file_usable?
		return false unless @@filepath
		return false unless File.exists?(@@filepath)
		return false unless File.readable?(@@filepath)
		return false unless File.writable?(@@filepath)
		return true
	end

	def self.create_file
		# create the movie file
		File.open(@@filepath,'w') unless file_exists?
		return file_usable?
	end

	def self.saved_movies
		movies = []
		if file_usable?
			file = File.new(@@filepath,'r')
			file.each_line do |line|
				movies << Movie.new.import_line(line.chomp)
			end
			file.close
		end
		return movies
	end

	def self.build_using_questions
		args = {}
		print "Movie title: "
		args[:title] = gets.chomp.strip
		print "Genre: "
		args[:genre] = gets.chomp.strip
		print "Length (min.): "
		args[:length] = gets.chomp.strip

		return self.new(args)

	end

	def initialize(args={})
		@title = args[:title] || ""
		@genre = args[:genre] || ""
		@length = args[:length] || ""
	end

	def import_line(line)
		line_array = line.split("\t")
		@title, @genre, @length = line_array
		return self
	end

	def save
		return false unless Movie.file_usable?
		File.open(@@filepath,'a') do |file|
			file.puts "#{[@title, @genre, @length].join("\t")}\n"
		end
		return true
	end

	def formatted_length
		display_minutes(@length)
	end
	
end
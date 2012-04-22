require 'movie'
require 'support/string_extend'
class Guide

	class Config
		@@actions = ['list', 'find', 'add', 'quit']
		def self.actions; @@actions; end
	end

	def initialize(path=nil)
		# locate the movie text file at path
		Movie.filepath = path 
		if Movie.file_usable?
			puts "Found movie file."
		# or create a new file
		elsif Movie.create_file
			puts "Created movie file."		
		# exit if create fails
		else
			puts "Exiting.\n\n"
			exit!
		end
	end

	def launch!
		introduction
		# action loop
		result = nil
		until result == :quit
			action, args = get_action
			result = do_action(action, args)
		end
		conclusion
	end

	def get_action
		action = nil
		# Keep asking for user input until we get a valid action
		until Guide::Config.actions.include?(action)
			puts "Actions: " + Guide::Config.actions.join(", ") if action
			print "> "
			user_response = gets.chomp
			args = user_response.downcase.strip.split(' ')
			action = args.shift
		end
		return action, args
	end

	def do_action(action, args=[])
		case action
		when 'list'
			list(args)
		when 'find'
			keyword = args.shift
			find(keyword)
		when 'add'
			add
		when 'quit'
			return :quit
		else
			puts "\nI don't understand that command.\n"
		end
	end

	def list(args=[])
		sort_order = args.shift
		sort_order = args.shift if sort_order == 'by'
		sort_order = "title" unless ['title', 'genre', 'length'].include?(sort_order)

		output_action_header("Listing movies")

		movies = Movie.saved_movies
		movies.sort! do |m1, m2|
			case sort_order
			when 'title'
				m1.title.downcase <=> m2.title.downcase
			when 'genre'
				m1.genre.downcase <=> m2.genre.downcase
			when 'length'
				m1.length.to_i <=> m2.length.to_i
			end
		end
		output_movie_table(movies)
		puts "Sort using: 'list genre' or 'list by genre'\n\n"
	end

	def add
		output_action_header("Add a genre")
		
		movie = Movie.build_using_questions

		if movie.save
			puts "\nMovie Added\n\n"
		else
			puts "\nSave Error: Movie not added\n\n"
		end
	end

	def find(keyword="")
		output_action_header("Find a movie")
		if keyword
			# search
			movies = Movie.saved_movies
			found = movies.select do |movie|
				movie.title.downcase.include?(keyword.downcase) ||
				movie.genre.downcase.include?(keyword.downcase) ||
				movie.length.to_i <= keyword.to_i
			end
			output_movie_table(found)
		else
			puts "Find using a key phase to search the movie list."
			puts "Examples: 'find titanic', 'find Comedy', 'find com'\n\n"
		end
	end

	def introduction
		puts "\n\n<<< Welcome to the Movie Finder >>>\n\n"
		puts "This is an interactive guide to help you find the movie you like.\n\n"
	end

	def conclusion
		puts "\n<<< Goodbye and Enjoy the movie! >>>\n\n\n"
	end		

	private

	def output_action_header(text)
		puts "\n#{text.upcase.center(60)}\n\n"
	end

	def output_movie_table(movies=[])
		print " " + "Title".ljust(30)
		print " " + "Genre".ljust(20)
		print " " + "Length".rjust(6) + "\n"
		puts "-" * 60
		movies.each do |movie|
			line = " " << movie.title.titleize.ljust(30)
			line << " " + movie.genre.titleize.ljust(20)
			line << " " + movie.formatted_length.rjust(6)
			puts line
		end
		puts "No listings found" if movies.empty?
		puts "-" * 60
	end

end
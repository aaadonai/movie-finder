class String

	def titleize
		self.split(' ').collect {|word| word.capitalize}.join(" ")
	end

end
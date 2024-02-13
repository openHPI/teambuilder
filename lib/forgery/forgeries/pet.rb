class Forgery::Pet < Forgery
	def self.pet_name
		dictionaries[:pet_name]
	end
end

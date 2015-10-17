module Associatable
	def has_many_through(name, through_name, source_name)
		define_method(name) do	
			self.send(through_name).map { |through_obj| through_obj.send(source_name)}					
		end

	end
end

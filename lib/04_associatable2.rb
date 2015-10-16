require_relative '03_associatable'
require 'byebug'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
      define_method(name.to_sym) do
        self.send(through_name).send(source_name)
      end

  end
end

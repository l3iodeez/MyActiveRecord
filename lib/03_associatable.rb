require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    options[:primary_key] ||= :id
    options[:class_name] ||= name.to_s.camelize.singularize
    options[:foreign_key] ||= "#{name.to_s.downcase}_id".to_sym
    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    options[:primary_key] ||= :id
    options[:class_name] ||= name.to_s.camelize.singularize
    options[:foreign_key] ||= "#{self_class_name.to_s.downcase}_id".to_sym
    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})

    define_method(name) do
      options_obj = BelongsToOptions.new(name, options)
      parent_class = options_obj.model_class

      f_key = self.send(options_obj.foreign_key)
      parent = parent_class.where({:id => f_key })
      return nil if parent.count < 1
      parent.first
    end
  end

  def has_many(name, options = {})
      options_obj = HasManyOptions.new(name, self, options)

    define_method(name) do
      target_class = options_obj.model_class

      p_key_value = self.send(options_obj.primary_key)
      f_key = options_obj.foreign_key
      options_obj.model_class.where({ f_key => p_key_value })
    

    end


    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end

require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject


  def self.columns

    sql_result = DBConnection.get_first_row("SELECT * FROM #{table_name}")
    columns = []

    sql_result.keys.each do |key|
      key = key.to_sym
      columns << key
    end
      columns << :id unless columns.include?(:id)

    columns
  end

  def self.finalize!
    columns.each do |key|
      define_method(key) do
        attributes[key]
      end

      define_method("#{key}=") do |object|
        attributes[key] = object
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.to_s.downcase.pluralize
  end

  def self.all
      parse_all(DBConnection.execute("SELECT * FROM #{table_name}"))
  end

  def self.parse(result)
    self.new(result)
  end

  def self.parse_all(results)
    results.map { |result| parse(result) }
  end

  def self.find(id)

    query_result = DBConnection.get_first_row("SELECT * FROM #{table_name} WHERE id = #{id}")
    return nil if query_result.nil?
    parse(query_result)
  end

  def initialize(params = {})

    self.class.finalize!

    params.each do |column_name, value|
      raise "unknown attribute '#{column_name}'" unless self.class.columns.include?(column_name.to_sym)
      send("#{column_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert

    attributes[:id] ||= DBConnection.get_first_row("SELECT MAX(id) AS count FROM #{self.class.table_name};")["count"] + 1

    column_name_string = attributes.keys.inject("#{self.class.table_name} (") { |acc, col| acc + "#{col}," }
    column_name_string = column_name_string[0...-1] + ")"

    value_string = attribute_values.inject("(") {|acc, val| acc + "?,"}
    value_string = value_string[0...-1] + ")"


    database = DBConnection.execute(<<-SQL, *attribute_values
      INSERT INTO
        #{column_name_string}
      VALUES
        #{value_string}
    SQL
    )
  end

  def update
    update_string = attributes.keys.inject('') { |acc, key| acc + "#{key} = ?,"  }
    update_string = update_string[0...-1]

    database = DBConnection.execute(<<-SQL, *attribute_values
      UPDATE
        #{self.class.table_name}
      SET
        #{update_string}
      WHERE
        id = #{attributes[:id]}
    SQL
    )


  end

  def save
    if attributes[:id]
      update
    else
      insert
    end
  end
end

require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_string = params.keys.inject("") { |acc, key| acc + "#{key} = ? AND "}
    where_string = where_string[0...-5]

    parse_all(
        DBConnection.execute(<<-SQL, *params.values
          SELECT
            *
          FROM
            #{self.table_name}
          WHERE
            #{where_string}
        SQL
        )
    )
  end
end

class SQLObject
  extend Searchable
end

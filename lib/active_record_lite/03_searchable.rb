require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    string = params.map{|key,value| "#{self.table_name}.#{key} = '#{value}'"}.join(' AND ')
    p string
    results = DBConnection.execute(<<-SQL)
      SELECT
      *
      FROM
      #{self.table_name}
      WHERE
      #{string}
    SQL
    results.map {|result| self.new(result) }
  end
end

class SQLObject
  extend Searchable
end

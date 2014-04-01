require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      p name
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      p through_options.model_class
      p through_options.primary_key
      p through_options.foreign_key
      p source_options.model_class
      p source_options.foreign_key
      result = DBConnection.execute(<<-SQL)
      SELECT
      #{source_options.model_class.table_name}.*
      FROM
      #{through_options.model_class.table_name}
      JOIN  #{source_options.model_class.table_name}
      ON #{through_options.model_class.table_name}.#{source_options.foreign_key} = 
      #{source_options.model_class.table_name}.#{source_options.primary_key}
      WHERE
      #{through_options.model_class.table_name}.id = #{self.send(through_options.foreign_key)}
      SQL
      p result
      source_options.model_class.new(result.first)
    end


  end
end

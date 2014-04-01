require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    @class_name.camelcase.constantize
  end

  def table_name
    "#{@class_name.downcase}s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @class_name = options[:class_name]   || name.to_s.camelcase.singularize
    @foreign_key = options[:foreign_key] || "#{@class_name.downcase}_id".to_sym
    @primary_key = options[:primary_key] || :id
  end

end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name]   || name.to_s.camelcase.singularize
    @foreign_key = options[:foreign_key] || "#{self_class_name.to_s}_id".downcase.to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    self.assoc_options
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => foreign_key).first
    end
    @assoc_options[name.to_sym] = options
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method(name) do
      primary_key = self.send(options.primary_key)
      results = options.model_class.where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end

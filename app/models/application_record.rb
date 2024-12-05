# frozen_string_literal: true

# Base ActiveRecord object
class ApplicationRecord < ActiveRecord::Base
  include GlobalHelpers
  include ValidationValues
  include ValidationMessages

  self.abstract_class = true

  class << self
    def postgres_db?
      connection.adapter_name == 'PostgreSQL'
    end

    # Generates the appropriate where clause for a JSON field based on the DB type
    def safe_json_where_clause(column:, hash_key:)
      "(#{column}->>'#{hash_key}' LIKE ?)"
    end

    # Generates the appropriate where clause for a regular expression based on the DB type
    def safe_regexp_where_clause(column:)
      "#{column} ~* ?"
    end
  end

  def sanitize_fields(*attrs)
    attrs.each do |attr|
      send(:"#{attr}=", ActionController::Base.helpers.sanitize(send(attr)))
    end
  end
end

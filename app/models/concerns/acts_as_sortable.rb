# frozen_string_literal: true

# Module that allows us to sort query results for paginated tables
module ActsAsSortable
  extend ActiveSupport::Concern

  class_methods do
    def update_numbers!(ids, parent:)
      # Ensure only records belonging to this parent are included.
      ids = ids.map(&:to_i) & parent.public_send(:"#{model_name.singular}_ids")
      return if ids.empty?

      update_numbers_postgresql!(ids) if ApplicationRecord.postgres_db?
      update_numbers_sequentially!(ids) unless ApplicationRecord.postgres_db?
    end

    private

    def update_numbers_postgresql!(ids)
      # Build an Array with each ID and its relative position in the Array
      values = ids.each_with_index.map { |id, i| "(#{id}, #{i + 1})" }.join(',')
      # Run a single UPDATE query for all records.
      query = <<~SQL
        UPDATE #{table_name} \
        SET number = svals.number \
        FROM (VALUES #{sanitize_sql(values)}) AS svals(id, number) \
        WHERE svals.id = #{table_name}.id;
      SQL
      connection.execute(query)
    end

    def update_numbers_sequentially!(ids)
      ids.each_with_index.map do |id, number|
        find(id).update(:number, number + 1)
      end
    end
  end
end

# frozen_string_literal: true

module Dmpopidor

  module Template

    def structured?
      questions.where(madmp_schema_id: nil).empty?
    end

  end

end
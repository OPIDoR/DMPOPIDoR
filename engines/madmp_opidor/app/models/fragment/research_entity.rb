# frozen_string_literal: true

# == Schema Information
#
# Table name: madmp_fragments
#
#  id              :integer          not null, primary key
#  additional_info :json
#  classname       :string
#  data            :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  answer_id       :integer
#  dmp_id          :integer
#  madmp_schema_id :integer
#  parent_id       :integer
#
# Indexes
#
#  index_madmp_fragments_on_answer_id        (answer_id)
#  index_madmp_fragments_on_madmp_schema_id  (madmp_schema_id)
#
# Foreign Keys
#
#  fk_rails_...  (answer_id => answers.id)
#  fk_rails_...  (madmp_schema_id => madmp_schemas.id)
#

#  id                        :integer          not null, primary key
#  data                      :json
#  answer_id                 :integer
#  madmp_schema_id :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  classname                 :string
#  dmp_id                    :integer
#  parent_id                 :integer

# Indexes

#  index_madmp_fragments_on_answer_id                  (answer_id)
#  index_madmp_fragments_on_madmp_schema_id  (madmp_schema_id)
module Fragment
  # ResearchEntity STI model
  class ResearchEntity < MadmpFragment
    def fundings
      Fragment::Funding.where(parent_id: id)
    end

    def structure_identification
      Fragment::Partner.where(parent_id: id, additional_info: { property_name: 'structureIdentification' }).first
    end

    def members
      Fragment::Partner.where(parent_id: id, additional_info: { property_name: 'members' })
    end

    def structure_managers
      Fragment::Contributor.where(parent_id: id, additional_info: { property_name: 'structureManager' })
    end

    def data_stewards
      Fragment::Contributor.where(parent_id: id, additional_info: { property_name: 'dataSteward' })
    end

    def properties
      'funding, structure_identification, members, structure_managers, data_stewards'
    end

    def self.sti_name
      'research_entity'
    end
  end
end

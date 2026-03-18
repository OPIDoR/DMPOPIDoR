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
#  madmp_fragments_dmp_id_idx                (dmp_id)
#  madmp_fragments_parent_id_idx             (parent_id)
#  madmp_fragments_plan_id_idx               (((data ->> 'plan_id'::text)))
#  madmp_fragments_research_output_id_idx    (((data ->> 'research_output_id'::text)))
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
  # LegalIssues STI model
  class LegalIssues < MadmpFragment
    def legal_reference
      Fragment::ResourceReference.where(parent_id: id)
    end

    def contributors
      Fragment::Contributor.where(parent_id: id)
    end

    def properties
      'legal_reference, contributors'
    end

    def self.sti_name
      'legal_issues'
    end
  end
end

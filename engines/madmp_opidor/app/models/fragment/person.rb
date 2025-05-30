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
  # Budget STI model
  class Person < MadmpFragment
    NON_RO_CLASSES = %w[meta project research_entity].freeze
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def roles(selected_research_outputs = nil, include_ro_names: false)
      contributors_list = contributors
      roles_list = []
      roles_aggregate = {}
      research_outputs = plan.research_outputs
      if selected_research_outputs.present?
        contributors_list = contributors_list
                            .select do |c|
                              c.research_output_id.nil? || selected_research_outputs.include?(c.research_output_id)
                            end
      end
      # This part of the code whecks if the contributor is a data contact for a research output
      # if so, the role will be displayed once as a concatenation of the research output abbreviation
      # Ex: Data contact (RO1, RO2)
      contributors_list.each do |c|
        if NON_RO_CLASSES.include?(c.parent&.classname)
          roles_list.push(c.data['role'])
          next
        end
        if include_ro_names
          if research_outputs.size.eql?(1)
            roles_list.push(c.data['role'])
            next
          end
          ro = research_outputs.find(c.research_output_id)
          if roles_aggregate[c.data['role']].nil?
            roles_aggregate[c.data['role']] = [ro.abbreviation]
          else
            roles_aggregate[c.data['role']].push(ro.abbreviation)
          end
        else
          roles_list.push(c.data['role'])
        end
      end
      roles_list += roles_aggregate.map { |k, v| "#{k} (#{v.join(', ')})" }
      roles_list.compact.sort
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def contributors
      Fragment::Contributor.where("(data->'person'->>'dbid')::int = ?", id)
    end

    def self.sti_name
      'person'
    end
  end
end

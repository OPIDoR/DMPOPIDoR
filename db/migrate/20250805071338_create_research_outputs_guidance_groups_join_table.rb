class CreateResearchOutputsGuidanceGroupsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_join_table :research_outputs, :guidance_groups
  end
end

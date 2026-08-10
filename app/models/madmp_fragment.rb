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
require 'jsonpath'

# rubocop:disable Metrics/ClassLength
# Object that represents a madmp_fragment
class MadmpFragment < ApplicationRecord
  include ValidationMessages
  include FragmentImport
  include ActionView::Helpers::NumberHelper

  # ================
  # = Associations =
  # ================

  belongs_to :answer, optional: true
  belongs_to :madmp_schema, class_name: 'MadmpSchema'
  belongs_to :dmp, class_name: 'Fragment::Dmp', foreign_key: 'dmp_id', optional: true
  has_many :children, class_name: 'MadmpFragment', foreign_key: 'parent_id', dependent: :destroy
  belongs_to :parent, class_name: 'MadmpFragment', foreign_key: 'parent_id', optional: true

  # ===============
  # = Validations =
  # ===============

  # validates :madmp_schema, presence: { message: PRESENCE_MESSAGE }
  validates :dmp, presence: true, unless: -> { classname.eql?('dmp') }

  # ================
  # = Single Table Inheritence =
  # ================
  self.inheritance_column = :classname
  scope :backup_policies, -> { where(classname: 'backup_policy') }
  scope :budgets, -> { where(classname: 'budgets') }
  scope :contributors, -> { where(classname: 'contributor') }
  scope :costs, -> { where(classname: 'cost') }
  scope :data_collections, -> { where(classname: 'data_collection') }
  scope :data_preservations, -> { where(classname: 'data_preservation') }
  scope :data_processings, -> { where(classname: 'data_processing') }
  scope :data_reuses, -> { where(classname: 'data_reuse') }
  scope :data_sharings, -> { where(classname: 'data_sharing') }
  scope :data_storages, -> { where(classname: 'data_storage') }
  scope :distributions, -> { where(classname: 'distribution') }
  scope :dmps, -> { where(classname: 'dmp') }
  scope :documentation_qualities, -> { where(classname: 'documentation_quality') }
  scope :ethical_issues, -> { where(classname: 'ethical_issue') }
  scope :funders, -> { where(classname: 'funder') }
  scope :fundings, -> { where(classname: 'funding') }
  scope :hosts, -> { where(classname: 'host') }
  scope :legal_issues, -> { where(classname: 'legal_issue') }
  scope :licences, -> { where(classname: 'licence') }
  scope :metas, -> { where(classname: 'meta') }
  scope :metadata_standards, -> { where(classname: 'metadata_standard') }
  scope :partners, -> { where(classname: 'partner') }
  scope :persons, -> { where(classname: 'person') }
  scope :personal_data_issues, -> { where(classname: 'personal_data_issue') }
  scope :projects, -> { where(classname: 'project') }
  scope :research_outputs, -> { where(classname: 'research_output') }
  scope :research_output_descriptions, -> { where(classname: 'research_output_description') }
  scope :resource_references, -> { where(classname: 'resource_reference') }
  scope :research_entities, -> { where(classname: 'research_entity') }
  scope :reused_datas, -> { where(classname: 'reused_data') }
  scope :specific_datas, -> { where(classname: 'specific_data') }
  scope :technical_resources, -> { where(classname: 'technical_resource') }

  # = Software specific classes =
  scope :software_descriptions, -> { where(classname: 'software_description') }
  scope :software_developments, -> { where(classname: 'software_development') }
  scope :software_documentations, -> { where(classname: 'software_documentation') }
  scope :software_runtimes, -> { where(classname: 'software_runtime') }
  scope :software_preservations, -> { where(classname: 'software_preservation') }
  scope :software_sharings, -> { where(classname: 'software_sharing') }
  scope :software_legal_issues, -> { where(classname: 'software_legal_issues') }
  scope :programming_languages, -> { where(classname: 'programming_language') }
  scope :dependency_references, -> { where(classname: 'dependency_reference') }
  scope :software_resource_references, -> { where(classname: 'software_resource_reference') }
  scope :software_valorisations, -> { where(classname: 'software_valorisation') }

  # =============
  # = Callbacks =
  # =============

  before_save   :set_defaults
  after_create  :update_parent_references
  after_destroy :update_parent_references
  after_save    -> { plan.touch }

  # =====================
  # = Nested Attributes =
  # =====================
  accepts_nested_attributes_for :answer, allow_destroy: true

  # ========================
  # = Public class methods =
  # ========================

  def plan
    if dmp.nil?
      Plan.includes(:template, :api_clients).find(data['plan_id'])
    else
      dmp.plan
    end
  end

  # Returns the schema associated to the JSON fragment
  def json_schema
    madmp_schema.schema
  end

  def dmp_fragments
    MadmpFragment.where(dmp_id: classname.eql?('dmp') ? id : dmp_id)
  end

  # Returns a human readable version of the structured answer
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
  def to_s
    full_data = get_full_fragment
    displayable = ''
    if json_schema['to_string']
      json_schema['to_string'].each do |pattern|
        # if it's a JsonPath pattern
        if pattern.first == '$'
          match = JsonPath.on(full_data, pattern)

          next if match.empty? || match.first.nil?

          displayable += case match.first
                         when Array
                           match.first.join('/')
                         when Integer, Float
                           number_with_delimiter(match.first)
                         else
                           match.first
                         end
        else
          displayable += pattern
        end
      end
    else
      displayable = full_data.to_s
    end
    displayable
  end
  # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

  # This method generates references to the child fragments in the parent fragment
  # it updates the json "data" field in the database
  # it groups the children fragment by classname and extracts the list of ids
  # to create the json structure needed to update the "data" field
  # this method should be called when creating or deleting a child fragment
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def update_children_references
    updated_data = data
    classified_children = children.group_by do |t|
      t.additional_info['property_name'] unless t.additional_info.nil?
    end

    madmp_schema.properties.each do |key, prop|
      if prop['type'].eql?('array') && prop['items']['type'].eql?('object')
        updated_data[key] = []
        if classified_children[key].present?
          updated_data[key] = classified_children[key].map { |c| { 'dbid' => c.id } }
          next
        end
      elsif prop['type'].eql?('object') && prop['template_name'].present?
        # dbid doesn't need to be regenerated for "person" properties
        # Person fragment don't have a parent_id set because they are used in multiple contributors
        # without this instruction, the app would set the dbid for the person prop as nil
        next if key.eql?('person')

        updated_data[key] = classified_children[key].nil? ? nil : { 'dbid' => classified_children[key][0].id }
      end
    end
    update!(data: updated_data)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize

  def update_parent_references
    return if classname.nil? || parent.nil?

    parent.update_children_references
  end

  # rubocop:disable Metrics/AbcSize
  def update_research_output_parameters(skip_broadcast: false)
    return unless plan.structured?

    return unless %w[research_output_description software_description physical_object_description].include?(classname)

    research_output.update(
      abbreviation: data['shortName'],
      title: data['title']
    )
    # update hasPersonalData config paramater only for research_output_description fragments
    if %w[physical_object_description research_output_description].include?(classname)
      ro_fragment = parent

      new_additional_info = ro_fragment.additional_info.merge(
        hasPersonalData: %w[Oui Yes].include?(data['containsPersonalData'])
      )
      ro_fragment.update(additional_info: new_additional_info)

    end
    return if skip_broadcast

    PlanChannel.broadcast_to(research_output.plan, {
                               target: 'research_output_infobox',
                               research_output_id: research_output.id,
                               payload: research_output.serialize_infobox_data
                             })
  end
  # rubocop:enable Metrics/AbcSize

  # This method return the fragment full record
  # It integrates its children into the JSON
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def get_full_fragment(with_ids: false, with_template_name: false, with_configuration: false,
                        with_guidance_groups: false)
    children = self.children
    editable_data = data
    # rubocop:disable Metrics/BlockLength
    editable_data.each do |prop, value|
      if value.nil?
        editable_data.delete(prop)
        next
      end

      if value.is_a?(Hash) && value['dbid'].present?
        child = if children.exists?(value['dbid'])
                  children.find(value['dbid'])
                else
                  MadmpFragment.find(value['dbid'])
                end
        child_data = child.get_full_fragment(
          with_ids:,
          with_template_name:,
          with_configuration:,
          with_guidance_groups:
        )
        editable_data = editable_data.merge(prop => child_data)
        next
      end

      if value.is_a?(Array)
        next if value.empty?

        fragment_tab = []
        value.each do |v|
          next if v.nil?

          if v.is_a?(Hash) && v['dbid'].present?
            child_data = if children.exists?(v['dbid'])
                           children.find(v['dbid'])
                         else
                           MadmpFragment.find(v['dbid'])
                         end
            fragment_tab.push(
              child_data.get_full_fragment(
                with_ids:,
                with_template_name:,
                with_configuration:,
                with_guidance_groups:
              )
            )
          else
            fragment_tab.push(v)
          end
          editable_data = editable_data.merge(prop => fragment_tab)
        end
        next
      end
      editable_data[prop] = value
    end
    # rubocop:enable Metrics/BlockLength
    editable_data = { 'id' => id, 'schema_id' => madmp_schema_id }.merge(editable_data) if with_ids
    editable_data = { 'template_name' => madmp_schema.name }.merge(editable_data) if with_template_name
    if with_configuration && classname.eql?('research_output')
      editable_data = { 'configuration' => additional_info.except('moduleId', 'property_name') }.merge(editable_data)
    end
    if with_guidance_groups && classname.eql?('research_output')
      editable_data = { 'guidance_groups' => research_output.guidance_groups.map do |gg|
        { 'id' => gg.id, 'name' => gg.name }
      end }.merge(editable_data)
    end

    editable_data
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # This method is called when a form is opened for the first time
  # It creates the whole tree of sub_fragments
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def instantiate
    save! if id.nil?

    new_data = data || {}
    madmp_schema.properties.each do |key, prop|
      if prop['type'].eql?('object') && prop['template_name'].present?

        sub_schema = MadmpSchema.find_by(name: prop['template_name'])

        next if sub_schema.classname.eql?('person') || new_data[key].present?

        sub_fragment = MadmpFragment.create!(
          data: {},
          answer_id: nil,
          dmp_id: dmp.id,
          parent_id: id,
          madmp_schema: sub_schema,
          classname: sub_schema.classname,
          additional_info: { property_name: key }
        )
        sub_fragment.instantiate

        new_data[key] = { 'dbid' => sub_fragment.id }
      elsif prop['type'].eql?('array') && prop['items']['type'].eql?('string')
        new_data[key] = []
      end
    end
    update!(data: new_data)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def handle_defaults(defaults)
    raw_import(defaults, madmp_schema) # if defaults.any?
  end

  def get_property(property_name)
    return if data.empty? || data[property_name].nil?

    if data[property_name]['dbid'].present?
      MadmpFragment.find(data[property_name]['dbid'])
    else
      data[property_name]
    end
  end

  # Get the research output fragment from the fragment hierarchy
  def research_output_fragment
    return nil if %w[meta dmp project research_entity budget].include?(classname)

    return self if classname.eql?('research_output')

    parent.research_output_fragment
  end

  def research_output_id
    return nil if research_output_fragment.nil?

    research_output_fragment.data['research_output_id']
  end

  def research_output
    return nil if research_output_fragment.nil?

    ResearchOutput.find(research_output_fragment.data['research_output_id'])
  end

  # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
  def update_meta_fragment
    meta_fragment = dmp.meta
    I18n.with_locale plan.template.locale do
      if classname.eql?('research_entity')
        entity_fragment = self
        dmp_title = format(_('"%{entity_name}" entity DMP'), entity_name: entity_fragment.data['name'])
        plan.update(title: dmp_title)
        meta_data = meta_fragment.data.merge(
          'title' => dmp_title, 'lastModifiedDate' => plan.updated_at.strftime('%F')
        )
        plan.update(title: dmp_title)
      elsif classname.eql?('project')
        project_fragment = self
        dmp_title = format(_('"%{project_title}" project DMP'), project_title: project_fragment.data['title'])
        meta_data = meta_fragment.data.merge(
          'title' => dmp_title, 'lastModifiedDate' => plan.updated_at.strftime('%F')
        )
        plan.update(title: dmp_title)
      else
        plan.update(title: meta_fragment.data['title'])
        meta_data = meta_fragment.data.merge(
          'lastModifiedDate' => plan.updated_at.strftime('%F')
        )
      end
      meta_fragment.update(data: meta_data)
    end
  end
  # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

  # =================
  # = Class methods =
  # =================

  # Validate the fragment data with the linked schema
  # and saves the result with the fragment data
  # rubocop:disable Metrics/AbcSize
  def self.validate_data(data, schema)
    schemer = JSONSchemer.schema(schema)
    unformated = schemer.validate(data).to_a
    validations = {}
    unformated.each do |valid|
      next if valid['type'].eql?('object')

      key = valid['data_pointer'][1..]
      if valid['type'].eql?('required')
        required = JsonPath.on(valid, '$..missing_keys').flatten
        required.each do |req|
          validations[req] ? validations[req].push('required') : validations[req] = ['required']
        end
      else
        validations[key] ? validations[key].push(valid['type']) : validations[key] = [valid['type']]
      end
    end
    validations
  end
  # rubocop:enable Metrics/AbcSize

  # Checks for a given dmp_id (and parent_id) if a fragment exists in the database
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
  def self.fragment_exists?(data, schema, dmp_id, parent_id = nil, current_fragment_id = nil)
    return false if schema.schema['unicity'].nil? || schema.schema['unicity'].empty?

    classname = schema.classname
    parent_id = nil if classname.eql?('person')
    unicity_properties = schema.schema['unicity']
    dmp_fragments = MadmpFragment.where(
      dmp_id:,
      parent_id:,
      classname:
    ).where.not(id: current_fragment_id)

    filtered_incoming_data = data.to_h.delete_if do |_, v|
      v.nil? || v.is_a?(Integer) || v.empty?
    end.slice(*unicity_properties)

    dmp_fragments.each do |fragment|
      filtered_db_data = fragment.data.delete_if do |_, v|
        v.nil? || v.is_a?(Integer) || v.empty?
      end.slice(*unicity_properties)
      next if filtered_db_data.nil? || filtered_db_data.empty?

      return fragment if filtered_db_data.eql?(filtered_incoming_data)
    end

    false
  end
  # rubocop:enable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize

  def self.deep_copy(fragment, answer_id, ro_fragment)
    fragment_copy = MadmpFragment.new(
      dmp_id: ro_fragment.dmp_id,
      parent_id: ro_fragment.id,
      answer_id:,
      madmp_schema_id: fragment.madmp_schema_id,
      additional_info: { property_name: fragment.additional_info['property_name'] }
    )
    fragment_copy.classname = fragment.classname
    fragment_copy.instantiate
    fragment_copy.raw_import(
      fragment.get_full_fragment,
      fragment.madmp_schema
    )
    fragment_copy
  end

  def self.find_sti_class(_type_name)
    self
  end

  def self.render_fragment_json(fragment, madmp_schema)
    {
      'fragment' => fragment.get_full_fragment(with_ids: true, with_template_name: true),
      'answer_id' => fragment.answer_id,
      'template' => {
        id: fragment.madmp_schema_id,
        name: madmp_schema.name,
        schema: madmp_schema.schema,
        dataType: madmp_schema.data_type,
        api_client: if madmp_schema.api_client.present?
                      {
                        id: madmp_schema.api_client_id,
                        name: madmp_schema.api_client.name
                      }
                    end
      }
    }
  end

  private

  # Initialize the data field
  def set_defaults
    self.data ||= {}
    self.additional_info ||= {}
    self.parent_id = nil if classname.eql?('person')
  end
end
# rubocop:enable Metrics/ClassLength

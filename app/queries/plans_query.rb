# frozen_string_literal: true

require 'jsonpath'

# Query object for fetching plans based on various parameters
class PlansQuery
  SORTABLE_COLUMNS = {
    'title' => 'title',
    'created' => 'created_at',
    'modified' => 'updated_at'
    # 'language' => 'language',
    # 'embargo' => 'embargo_date',
    # 'keyword' => 'keyword'
  }.freeze
  AVAILABLE_LANGUAGES = {
    'eng' => 'en-GB',
    'fra' => 'fr-FR'
  }.freeze
  SORT_DIRECTIONS = %w[asc desc].freeze

  DEFAULT_COUNT = 20
  DEFAULT_SORT_BY = 'created'
  DEFAULT_SORT_DIRECTION = 'desc'

  def initialize(params)
    @params = params
  end

  def call
    scope = Plan.includes(:template, :json_plans).all
    scope = apply_created_before(scope)
    scope = apply_created_after(scope)
    scope = apply_modified_before(scope)
    scope = apply_modified_after(scope)
    scope = apply_languages(scope)
    scope = apply_contact_ids(scope)
    scope = apply_contributor_ids(scope)
    scope = apply_datasets_ids(scope)
    scope = apply_metadata_standard_ids(scope)
    scope = apply_dmp_ids(scope)
    scope = apply_funder_ids(scope)
    scope = apply_grant_ids(scope)
    scope = apply_ethical_issues_exist(scope)
    scope = apply_embargo_before(scope)
    scope = apply_embargo_after(scope)

    scope = apply_limit_offset(scope)
    apply_sorting(scope)
  end

  def apply_created_before(plans)
    return plans unless @params[:created_before].present?

    plans.where('created_at < ?', Time.parse(@params[:created_before]))
  end

  def apply_created_after(plans)
    return plans unless @params[:created_after].present?

    plans.where('created_at > ?', Time.parse(@params[:created_after]))
  end

  def apply_modified_before(plans)
    return plans unless @params[:modified_before].present?

    plans.where('updated_at < ?', Time.parse(@params[:modified_before]))
  end

  def apply_modified_after(plans)
    return plans unless @params[:modified_after].present?

    plans.where('updated_at > ?', Time.parse(@params[:modified_after]))
  end

  def apply_languages(plans)
    return plans unless @params[:languages].present?

    valid_languages = @params[:languages].select { |lang| AVAILABLE_LANGUAGES.key?(lang) }
    return plans if valid_languages.empty?

    plans.filter do |plan|
      JsonPath.on(plan.json_plans.first.data, '$.meta.dmpLanguage').any? { |lang| valid_languages.include?(lang) }
    end
  end

  def apply_contact_ids(plans)
    return plans unless @params[:contact_ids].present?

    allowed_contact_ids = @params[:contact_ids].map { |c| JSON.parse(c) }.to_set { |c| [c['type'], c['identifier']] }
    plans.filter do |plan|
      contact_persons = extract_json_path_data(plan, '$.meta.contact[*].person')
      contact_persons.any? do |p|
        allowed_contact_ids.include?([p['idType'], p['personId']])
      end
    end
  end

  def apply_contributor_ids(plans)
    return plans unless @params[:contributor_ids].present?

    allowed_contributor_ids = @params[:contributor_ids].map { |c| JSON.parse(c) }
                                                       .to_set do |c|
      [
        c['type'], c['identifier']
      ]
    end
    plans.filter do |plan|
      contributor_persons = extract_json_path_data(plan, '$..person')
      contributor_persons.any? do |p|
        allowed_contributor_ids.include?([p['idType'], p['personId']])
      end
    end
  end

  def apply_datasets_ids(plans)
    return plans unless @params[:datasets_ids].present?

    allowed_datasets_ids = @params[:datasets_ids].map { |c| JSON.parse(c) }.to_set { |c| [c['type'], c['identifier']] }
    plans.filter do |plan|
      datasets = extract_json_path_data(plan, '$.researchOutput[*].researchOutputDescription')
      datasets.any? do |p|
        allowed_datasets_ids.include?([p['idType'], p['datasetId']])
      end
    end
  end

  def apply_metadata_standard_ids(plans)
    return plans unless @params[:metadata_standard_ids].present?

    allowed_metadata_standard_ids = @params[:metadata_standard_ids].map { |c| JSON.parse(c) }.to_set do |c|
      [
        c['type'], c['identifier']
      ]
    end
    plans.filter do |plan|
      metadata_standards = extract_json_path_data(plan, '$.researchOutput[*].documentationQuality.metadataStandard[*]')
      metadata_standards.any? do |m|
        allowed_metadata_standard_ids.include?([m['idType'], m['metadataStandardId']])
      end
    end
  end

  def apply_dmp_ids(plans)
    return plans unless @params[:dmp_ids].present?

    allowed_dmp_ids = @params[:dmp_ids].map { |c| JSON.parse(c) }.to_set { |c| [c['type'], c['identifier']] }
    plans.filter do |plan|
      dmp_id = extract_json_path_data(plan, '$.meta')
      dmp_id.any? do |d|
        allowed_dmp_ids.include?([d['idType'], d['dmpId']])
      end
    end
  end

  def apply_funder_ids(plans)
    return plans unless @params[:funder_ids].present?

    allowed_funder_ids = @params[:funder_ids].map { |c| JSON.parse(c) }.to_set { |c| [c['type'], c['identifier']] }
    plans.filter do |plan|
      funders = extract_json_path_data(plan, '$.project.funding[*].funder')
      funders.any? do |f|
        allowed_funder_ids.include?([f['idType'], f['funderId']])
      end
    end
  end

  def apply_grant_ids(plans)
    return plans unless @params[:grant_ids].present?

    allowed_grant_ids = @params[:grant_ids].map { |c| JSON.parse(c) }.to_set { |c| [c['identifier']] }
    plans.filter do |plan|
      fundings = extract_json_path_data(plan, '$.project.funding[*]')
      fundings.any? do |f|
        allowed_grant_ids.include?([f['grantId']])
      end
    end
  end

  def apply_ethical_issues_exist(plans)
    return plans unless @params[:ethical_issues_exist].present?

    yes_values = %w[Oui Yes]
    no_values = %w[Non No "Ne sais pas" Unknown]

    ethical_issues_exist = @params[:ethical_issues_exist] == 'true'
    plans.filter do |plan|
      ethical_issues = extract_json_path_data(plan, '$.researchOutput[*].researchOutputDescription.hasEthicalIssues')
      ethical_issues_exist ? yes_values.intersect?(ethical_issues) : no_values.intersect?(ethical_issues)
    end
  end

  def apply_embargo_before(plans)
    plans
  end

  def apply_embargo_after(plans)
    plans
  end

  def apply_limit_offset(plans)
    offset = @params[:offset].to_i
    limit = @params[:limit].to_i.eql?(0) ? DEFAULT_COUNT : @params[:limit].to_i
    plans.drop(offset).take(limit)
  end

  def apply_sorting(plans)
    plans
  end

  private

  def extract_json_path_data(plan, path)
    JsonPath.on(plan.json_plans.first.data, path)
  end
end

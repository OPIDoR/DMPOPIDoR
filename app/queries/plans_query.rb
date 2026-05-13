# frozen_string_literal: true

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

  def initialize(params)
    @params = params
  end

  def call
    scope = Plan.includes(:template).all
    scope = apply_created_before(scope)
    scope = apply_created_after(scope)
    scope = apply_modified_before(scope)
    scope = apply_modified_after(scope)
    apply_languages(scope)
    # scope = apply_contact_ids(scope)

    # plans = Plan.includes(:template, :org, :identifier, :users)
    # plans = plans.where(id: params[:id]) if params[:id].present?
    # plans = plans.where(org_id: params[:org_id]) if params[:org_id].present?
    # plans = plans.where(template_id: params[:template_id]) if params[:template_id].present?
    # plans = plans.joins(:users).where(users: { id: params[:user_id] }) if params[:user_id].present?
    # plans
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

    plans.where(template: { locale: valid_languages.map { |lang| AVAILABLE_LANGUAGES[lang] } })
  end

  # def apply_contact_ids(plans)
  #   return plans unless @params[:contact_ids].present?

  #   dmp_ids = Plan.dmp_ids(plans)
  #   contact_frags = MadmpFragment.where("additional_info ->> 'property_name' = 'contact' AND dmp_id IN (?)", dmp_ids)
  #   # plans.joins(:users).where(users: { id: @params[:contact_ids] })
  # end
end

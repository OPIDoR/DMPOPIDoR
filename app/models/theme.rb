# frozen_string_literal: true

# == Schema Information
#
# Table name: themes
#
#  id           :integer          not null, primary key
#  description  :text
#  translations :json
#  slug         :string
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

# Object that represents a question/guidance theme
class Theme < ApplicationRecord
  # Before save & create, generate the slug
  before_save :generate_slug

  # ================
  # = Associations =
  # ================

  has_and_belongs_to_many :questions, join_table: 'questions_themes'
  has_and_belongs_to_many :guidances, join_table: 'themes_in_guidance'
  has_many :answers, through: :questions

  # ===============
  # = Validations =
  # ===============

  validates :title, presence: { message: PRESENCE_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  scope :search, lambda { |term|
    search_pattern = "%#{term}%"
    where('lower(title) LIKE lower(?) OR description LIKE lower(?)',
          search_pattern, search_pattern)
  }

  # ===========================
  # = Public instance methods =
  # ===========================

  # The title of the Theme
  #
  # Returns String
  def to_s
    title
  end

  def to_slug
    title.parameterize.truncate(80, omission: '')
  end

  # generate slug from title
  def generate_slug
    self.slug = title.parameterize if title
  end
end

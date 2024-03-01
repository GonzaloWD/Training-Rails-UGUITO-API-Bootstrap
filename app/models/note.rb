# == Schema Information
#
# Table name: notes
#
#  id         :bigint(8)        not null, primary key
#  title      :string           not null
#  content    :string           not null
#  note_type  :integer          not null
#  user_id    :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  enum note_type: { review: 0, critique: 1 }

  validates :title, :content, :note_type, presence: true
  validate :validate_content_length

  belongs_to :user
  has_one :utility, through: :user

  def word_count
    content&.scan(/\p{alpha}+|\d+(?:\.\d+)*/)&.length || 0
  end

  def content_length
    count = word_count
    return 'short' if count <= utility.short_content_length
    return 'medium' if count <= utility.medium_content_length
    'long'
  end

  private

  def validate_content_length
    errors.add(:content, I18n.t('note.validate_content_length')) unless valid_content_count?
  end

  def valid_content_count?
    note_type != 'review' || word_count <= utility.short_content_length
  end
end

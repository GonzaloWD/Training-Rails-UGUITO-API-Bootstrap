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
  validates :title, :content, :note_type, :user_id, presence: true
  validate :review_must_be_short

  belongs_to :user
  has_one :utility, through: :user

  scope :with_type_page_order, lambda { |filtering_params, order, page, page_size|
                                 where(filtering_params).order(created_at: order)
                                                        .page(page)
                                                        .per(page_size)
                               }

  def word_count
    content.scan(/\p{alpha}+|\d+(?:\.\d+)*/).length
  end

  def content_length
    count = word_count
    return 'short' if count <= utility.short_content
    return 'medium' if count <= utility.medium_content
    'long'
  end

  def review_must_be_short
    errors.add(:content, I18n.t('note.review_must_be_short')) unless valid_content_count?
  end

  def valid_content_count?
    content.nil? ||
      (note_type != 'review' || word_count <= (utility&.short_content || 50))
  end
end

class Job < ApplicationRecord
  validates :wage_upper_bound, presence: true
  validates :wage_lower_bound, presence: true
  validates :wage_lower_bound, numericality: {greater_than: 0}
  validates :title, presence: true
  scope :published, -> { where(is_hidden: false) }
  scope :recent, -> { order('created_at DESC') }
  has_many :resumes
  def publish!
    self.is_hidden = false
    self.save
  end

  def hide!
    self.is_hidden = true
    self.save
  end
  has_many :job_relationships
  has_many :members, through: :job_relationships, source: :user
end

class Order < ApplicationRecord
  belongs_to :delivery, optional: true

  validates :commodity, :location, :quantity, presence: true
  validates :quantity, numericality: { less_than_or_equal_to: 100, greater_than: 0 }

  def received?
    ack?
  end

  def accepted?
    received? && delivery.present?
  end

  def delivered?
    received? && accepted? && delivery.delivered?
  end
end

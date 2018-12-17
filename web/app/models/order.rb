class Order < ApplicationRecord
  belongs_to :delivery, optional: true

  validates :commodity, :location, :quantity, presence: true
  validates :quantity, numericality: { less_than_or_equal_to: 100, greater_than: 0 }

  def status
    return 'waiting' unless ack?
    return 'processing' if delivery.nil?
    return 'in delivery' unless delivery.delivered?
    'delivered'
  end

  def as_json(args)
    super.merge({
      status: status
    })
  end
end

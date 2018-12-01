class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :commodity
      t.string :quantity
      t.string :location
      t.references :delivery, foreign_key: true
      t.boolean :ack, default: false, null: false

      t.timestamps
    end
  end
end

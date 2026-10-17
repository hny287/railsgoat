# frozen_string_literal: true
class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.references :user, null: false
      t.references :approver
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :description
      t.string :receipt_url
      t.string :state, null: false, default: "submitted"
      t.datetime :paid_at
      t.timestamps
    end
  end
end

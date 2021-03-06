# frozen_string_literal: true

class CreateCards < ActiveRecord::Migration[6.0]
  def change
    create_table :cards do |t|
      t.belongs_to :user, index: true
      t.string :brand
      t.integer :exp_month
      t.integer :exp_year
      t.string :last_digits

      t.timestamps
    end
  end
end

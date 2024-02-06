# frozen_string_literal: true

class CreateSignatures < ActiveRecord::Migration[7.1]
  def change
    create_table :signatures do |t|
      t.string :name, null: false
      t.string :uid, null: false
      t.json :device, null: false

      t.timestamps
    end
  end
end

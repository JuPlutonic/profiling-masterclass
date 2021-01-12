class CreateSessions < ActiveRecord::Migration[6.1]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :browser
      t.integer :duration
      t.date :date
      t.string :country

      t.timestamps
    end
  end
end

class CreateQuotes < ActiveRecord::Migration[7.2]
  def change
    create_table :quotes do |t|
      t.string :name, null: false
      t.datetime :validated_at, null: true
      t.timestamps
    end
    add_index :quotes, :validated_at
  end
end

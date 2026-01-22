class CreateStructuredCausalExplanations < ActiveRecord::Migration[8.0]
  def change
    create_table :structured_causal_explanations do |t|
      t.references :medical_case, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :finding
      t.string :impression
      t.boolean :certainty

      t.timestamps
    end
  end
end

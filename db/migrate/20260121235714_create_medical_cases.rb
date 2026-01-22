class CreateMedicalCases < ActiveRecord::Migration[8.0]
  def change
    create_table :medical_cases do |t|
      t.string :case_id
      t.text :report_text
      t.text :causal_exploration_text
      t.json :checklist_data
      t.json :image_paths

      t.timestamps
    end
    add_index :medical_cases, :case_id, unique: true
  end
end

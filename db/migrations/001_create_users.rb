Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :username, null: false
      String :email, null: false
      String :password_digest, null: false
      String :reset_token_digest
      DateTime :reset_token_expires_at
      DateTime :created_at
      DateTime :updated_at

      index :username, unique: true
      index :email, unique: true
    end
  end
end

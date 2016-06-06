class AlterOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :order_number, :string
  	add_column :orders, :order_type, :integer
  	add_column :orders, :security_deposit, :integer
  	add_column :app_users, :customer_service_account, :string
  	add_column :app_users, :business_type, :string
  	add_column :app_users, :business_status, :string
  	add_column :app_users, :credit_worthy, :string
  	add_column :app_users, :customer_contract, :string
  	add_column :app_users, :ssn, :string
  	add_column :app_users, :dob, :date
  end
end
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create(:email=>'pratibha.praveen@spa-systems.com',:password=>'111111',:password_confirmation=>'111111',:name=>'Pratibha Praveen')
user.role = 'super_admin'
user.save
user = User.create(:email=>'admin@example.com',:password=>'111111',:password_confirmation=>'111111',:name=>'Admin User')
user.role = 'admin'
user.save
user = User.create(:email=>'service@example.com',:password=>'111111',:password_confirmation=>'111111',:name=>'Service Provider')
user.role = 'service_provider'
user.save

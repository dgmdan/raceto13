# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

NotificationType.create [
  { id: 1, name: 'hit', description: 'When my score increases', created_at: DateTime.now,
    updated_at: DateTime.now },
  { id: 2, name: 'conclude', description: 'When the pool ends', created_at: DateTime.now,
    updated_at: DateTime.now }
]

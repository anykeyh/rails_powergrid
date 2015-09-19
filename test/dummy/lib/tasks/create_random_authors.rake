namespace :db do
  task :populate => :environment do
    require 'faker'

    800.times do
      a = Author.create first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, nationality: Faker::Address.country

      author_start_publication = Faker::Date.between(100.years.ago, 5.years.ago)

      (1..55).to_a.sample.times do
        Book.create name: Faker::Lorem.sentence,
          isbn_number: Faker::Code.isbn,
          author: a,
          published_at: Faker::Date.between(author_start_publication, author_start_publication+50.years)
      end
    end
  end
end

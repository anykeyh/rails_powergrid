model Author do |query|
  query.select("COUNT(*) AS number_of_books")
  .joins("LEFT JOIN books ON (books.author_id = authors.id)")
  .group(:author_id)
end

column :first_name
column :last_name

column :book_num, editable: false, label: "Number of books" do
  get do |model|
    model.number_of_books
  end

  sort_by do |query, direction|
    query.order("number_of_books #{direction}")
  end
end

default_actions
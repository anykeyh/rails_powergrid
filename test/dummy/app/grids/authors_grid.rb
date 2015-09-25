model Author do |query|
  query.select("COUNT(*) AS number_of_books")
  .joins("LEFT JOIN books ON (books.author_id = authors.id)")
  .group(:author_id)
end

column :first_name, label: "First name", hint: "You can let it empty", fieldset: "Common"
column :last_name, label: "Last name", hint: "Last name of the author", fieldset: "Common"

column :book_num, editable: false, label: "Number of books" do
  type :number

  get do |model|
    model.number_of_books
  end

  sort_by do |query, direction|
    query.order("number_of_books #{direction}")
  end

  aggregate true

  filter do |model, operator, value|
    "number_of_books #{operator} #{value}"
  end
end

default_actions
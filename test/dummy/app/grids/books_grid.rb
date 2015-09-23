model Book do |query|
  query.select("authors.first_name").joins("LEFT JOIN authors ON (authors.id = books.author_id)")
end

column :name
column :author, sortable: true do
  get do |model|
    model.author.full_name
  end

  sort_by do |query, direction|
    query.order("authors.last_name #{direction}")
  end

  filter do |query, operator, value|
    "authors.last_name #{operator} #{value}"
  end
end

column :isbn_number
column :author_id, visible: false
#column :published_at

default_actions
model User do |query|
  #query.includes(:category)
  query.select(:updated_at).where("email LIKE ?", "test%")

end

column :id, visible: false
column :name, label: "Some very long name"

column :role, label: "Role", allow_blank: true

column :test, label: "Just A test", sortable: true, renderer: :money do
  set do |model, value|
    model.name = "Test name! #{value}"
  end

  get do |model|
    model.updated_at
  end
end

#column :"category.name", label: "Category name", editor: :select, editor_opts: => "/categories/index.json" do
#  set do |model, value|
#    model.category_id = value
#  end
#end


column :email, label: "E-mail", width: 160

#default_actions
action :audit
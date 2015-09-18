model User do |query|
  query = query.select(:role_id, :updated_at)
  query = query.joins("LEFT JOIN roles ON roles.id = users.role_id")
end

column :id, visible: false
column :name, label: "Some very long name"

column :role, label: "Role", allow_blank: true

column :"role.name" do
  set do |model, value|
    if model.role == nil
      model.role = Role.new
    end

    model.role.name = value
  end
end

column :email, label: "E-mail", width: 160

default_actions
#action :audit
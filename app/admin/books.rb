ActiveAdmin.register Book do
  filter :title
  filter :genre
  filter :publisher
  filter :year
  filter :created_at
  filter :updated_at

  includes :utility, :user

  permit_params :title, :publisher, :year, :genre, :author, :image, :user_id, :utility_id
  index do
    selectable_column
    id_column
    column :title
    column :author
    column :genre
    column :utility
    column :publisher
    actions
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :publisher
      f.input :year
      f.input :genre
      f.input :author
      f.input :image
      f.input :image
      f.input :user_id, label: 'User', as: :select, collection: User.all.map { |user|
        ["#{user.first_name} #{user.last_name}", user.id]
      }
      f.input :utility_id, label: 'Utility', as: :select, collection: Utility.all.map { |utility|
        [utility.name, utility.id]
      }
    end
    f.actions
  end
end

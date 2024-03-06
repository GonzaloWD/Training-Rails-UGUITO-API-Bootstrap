ActiveAdmin.register Book do
  filter :title
  filter :genre
  filter :publisher
  filter :year
  filter :created_at
  filter :updated_at

  permit_params :title, :publisher, :year, :genre, :author, :image, :user_id, :utility_id
  index do
    selectable_column
    id_column
    column :title
    column :author
    column :genre
    column :utility_id
    column :user_id
    column :publisher
    column :created_at
    column :updated_at
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
      f.input :user_id
      f.input :utility_id
    end
    f.actions
  end
end

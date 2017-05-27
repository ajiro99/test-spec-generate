json.extract! project, :id, :project_name, :description, :created_at, :updated_at
json.url project_url(project, format: :json)
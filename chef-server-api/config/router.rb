Merb::Router.prepare do
  resources :users

  # Nodes
  resources :nodes, :id => /[^\/]+/
  match('/nodes/:id/cookbooks',
        :id => /[^\/]+/,
        :method => 'get').
    to(:controller => "nodes", :action => "cookbooks")
  # Roles
  resources :roles

  # Status
  match("/status").to(:controller => "status", :action => "index").name(:status)

  # Clients
  match("/clients", :method=>"post").to(:controller=>'clients', :action=>'create')
  match("/clients", :method=>"get").to(:controller=>'clients', :action=>'index').name(:clients)
  match("/clients/:id", :id => /[\w\.-]+/, :method=>"get").to(:controller=>'clients', :action=>'show').name(:client)
  match("/clients/:id", :id => /[\w\.-]+/, :method=>"put").to(:controller=>'clients', :action=>'update')
  match("/clients/:id", :id => /[\w\.-]+/, :method=>"delete").to(:controller=>'clients', :action=>'destroy')

  # Search
  resources :search
  match('/search/reindex', :method => 'post').to(:controller => "search", :action => "reindex")

  # Cookbooks
  match('/nodes/:id/cookbooks', :method => 'get').to(:controller => "nodes", :action => "cookbooks")

  scope.match("/cookbooks",
              :method => 'get'
              ).to(:controller => "cookbooks", :action => "index")

  scope.match("/cookbooks/:cookbook_name/:cookbook_version",
              :method => 'put',
              :cookbook_name => /[\w\.]+/,
              :cookbook_version => /\d+\.\d+\.\d+/
              ).to(:controller => "cookbooks", :action => "update")

  scope.match("/cookbooks/:cookbook_name/:cookbook_version",
              :method => 'get',
              :cookbook_name => /[\w\.]+/,
              :cookbook_version => /(\d+\.\d+\.\d+|_latest)/
              ).to(:controller => "cookbooks", :action => "show")

  scope.match("/cookbooks/:cookbook_name/:cookbook_version",
              :method => 'delete',
              :cookbook_name => /[\w\.]+/,
              :cookbook_version => /(\d+\.\d+\.\d+|_latest)/
              ).to(:controller => "cookbooks", :action => "destroy")

  scope.match("/cookbooks/:cookbook_name",
              :method => 'get',
              :cookbook_name => /[\w\.]+/
              ).to(:controller => "cookbooks", :action => "show_versions").name(:cookbook)

  scope.match("/cookbooks/:cookbook_name/:cookbook_version/files/:checksum",
              :cookbook_name => /[\w\.]+/,
              :cookbook_version => /(\d+\.\d+\.\d+|_latest)/
              ).to(
                   :controller => "cookbooks",
                   :action => "show_file"
                   ).name(:cookbook_file)

  # Sandbox
  scope.match('/sandboxes', :method => 'get').to(:controller => "sandboxes", :action => "index").name(:sandboxes)
  scope.match('/sandboxes', :method => 'post').to(:controller => "sandboxes", :action => "create")
  scope.match('/sandboxes/:sandbox_id', :method => 'get', :sandbox_id => /[\w\.]+/).to(:controller => "sandboxes", :action => "show").name(:sandbox)
  scope.match('/sandboxes/:sandbox_id', :method => 'put', :sandbox_id => /[\w\.]+/).to(:controller => "sandboxes", :action => "update")
  scope.match('/sandboxes/:sandbox_id/:checksum', :method => 'put', :sandbox_id => /[\w\.]+/, :checksum => /[\w\.]+/).to(:controller => "sandboxes", :action => "upload_checksum").name(:sandbox_checksum)
  scope.match('/sandboxes/:sandbox_id/:checksum', :method => 'get', :sandbox_id => /[\w\.]+/, :checksum => /[\w\.]+/).to(:controller => "sandboxes", :action => "download_checksum")

  # Data
  match("/data/:data_bag_id/:id", :method => 'get').to(:controller => "data_item", :action => "show").name("data_bag_item")
  match("/data/:data_bag_id", :method => 'post').to(:controller => "data_item", :action => "create").name("create_data_bag_item")
  match("/data/:data_bag_id/:id", :method => 'put').to(:controller => "data_item", :action => "update").name("update_data_bag_item")
  match("/data/:data_bag_id/:id", :method => 'delete').to(:controller => "data_item", :action => "destroy").name("destroy_data_bag_item")
  resources :data, :controller => "data_bags"

  match('/').to(:controller => 'main', :action =>'index').name(:top)

end

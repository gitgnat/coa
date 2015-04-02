namespace :es do
  require 'elasticsearch'

  ES_HOST = 'es.service.dev0.consul'
  ES_PORT = 9200
  ES_URL = "http://#{ES_HOST}:#{ES_PORT}"

  desc "info"
  task :info  do
    sh "curl #{ES_URL}?pretty"
    c = Client.new
    p c.cluster.health
    # --> GET _cluster/health {}
    # => "{"cluster_name":"elasticsearch" ... }"
    # p c.index index: 'myindex', type: 'mytype', id: 'custom', body: { title: "Indexing from my client" }
    # --> PUT myindex/mytype/custom {} {:title=>"Indexing from my client"}
    # => "{"ok":true, ... }"
  end

  task :index_info, [:index] do |t,arg|
    arg.with_defaults(index: 'edu')
    Client.new.indices.get index: arg.index
  end

  desc "delete an index: default=edu"
  task :delete, [:index] do |t,arg|
    arg.with_defaults(index: 'edu')
    Client.new.indices.delete index: arg.index
  end

  desc "create an index: default=edu"
  task :create, [:index] do |t,arg|
    arg.with_defaults(index: 'edu')
    es = YAML.load(File.read PROJ_DIR + "/es/schema.yaml")
    body = es.to_h
    puts JSON.pretty_generate body
    r = Client.new.indices.create index: arg.index, body: body
    puts r.green
  end

  desc "clobber"
  task :clobber do
  end

  class Client
    include Elasticsearch::API
    CONNECTION = ::Faraday::Connection.new url: ES_URL

    def perform_request(method, path, params, body)
      puts "--> #{method.upcase} #{path} #{params} #{body}"
      CONNECTION.run_request method.downcase.to_sym, path,
      ( body ? MultiJson.dump(body): nil ),
      {'Content-Type' => 'application/json'}
    end
  end
end

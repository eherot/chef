#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Nuo Yan (<nuo@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/config'
require 'chef/mixin/params_validate'
require 'chef/mixin/from_file'
require 'chef/mixin/couchable'
require 'chef/couchdb'
require 'chef/data_bag_item'
require 'chef/index_queue'
require 'extlib'
require 'json'

class Chef
  class DataBag 
    
    include Chef::Mixin::FromFile
    include Chef::Mixin::ParamsValidate
    include Chef::IndexQueue::Indexable
    
    include Chef::Mixin::Couchable
    extend  Chef::Mixin::Couchable::ClassMethods
    
    database :data_bags,
      "version" => 2,
      "language" => "javascript",
      "views" => {
        "all" => {
          "map" => <<-EOJS
          function(doc) { 
            if (doc.chef_type == "data_bag") {
              emit(doc.name, doc);
            }
          }
          EOJS
        },
        "all_id" => {
          "map" => <<-EOJS
          function(doc) { 
            if (doc.chef_type == "data_bag") {
              emit(doc.name, doc.name);
            }
          }
          EOJS
        },
        "entries" => {
          "map" => <<-EOJS
          function(doc) {
            if (doc.chef_type == "data_bag_item") {
              emit(doc.data_bag, doc.raw_data.id);
            }
          }
          EOJS
        }
      }

    attr_accessor :couchdb_rev, :couchdb_id
    
    # Create a new Chef::DataBag
    def initialize
      @name = '' 
      @couchdb_id = nil
    end

    def name(arg=nil) 
      set_or_return(
        :name,
        arg,
        :regex => /^[\-[:alnum:]_]+$/
      )
    end

    def to_hash
      result = {
        "name" => @name,
        'json_class' => self.class.name,
        "chef_type" => "data_bag",
      }
      result["_rev"] = @couchdb_rev if @couchdb_rev
      result
    end

    # Serialize this object as a hash 
    def to_json(*a)
      to_hash.to_json(*a)
    end
    
    # Create a Chef::Role from JSON
    def self.json_create(o)
      bag = new
      bag.name(o["name"])
      bag.couchdb_rev = o["_rev"] if o.has_key?("_rev")
      bag.couchdb_id = o["_id"] if o.has_key?("_id")
      bag
    end
    
    def self.list(inflate=false)
      r = Chef::REST.new(Chef::Config[:chef_server_url])
      if inflate
        response = Hash.new
        Chef::Search::Query.new.search(:data) do |n|
          response[n.name] = n
        end
        response
      else
        r.get_rest("data")
      end
    end
    
    # Load a Data Bag by name via the RESTful API
    def self.load(name)
      r = Chef::REST.new(Chef::Config[:chef_server_url])
      r.get_rest("data/#{name}")
    end
    
    def destroy
      r = Chef::REST.new(Chef::Config[:chef_server_url])
      r.delete_rest("data/#{@name}")
    end
    
    # Save the Data Bag via RESTful API
    def save
      r = Chef::REST.new(Chef::Config[:chef_server_url])
      begin
        r.put_rest("data/#{@name}", self)
      rescue Net::HTTPServerException => e
        if e.response.code == "404"
          r.post_rest("data", self)
        else
          raise e
        end
      end
      self
    end
    
    #create a data bag via RESTful API
    def create
      r = Chef::REST.new(Chef::Config[:chef_server_url])
      r.post_rest("data", self)
      self
    end

    # List all the items in this Bag from CouchDB
    # The self.load method does this through the REST API
    def list(inflate=false)
      rs = nil 
      if inflate
        rs = @couchdb.get_view("data_bags", "entries", :include_docs => true, :startkey => @name, :endkey => @name)
        rs["rows"].collect { |r| r["doc"] }
      else
        rs = @couchdb.get_view("data_bags", "entries", :startkey => @name, :endkey => @name)
        rs["rows"].collect { |r| r["value"] }
      end
    end
    
    # As a string
    def to_s
      "data_bag[#{@name}]"
    end

  end
end


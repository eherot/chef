#
# Author:: Daniel DeLeo (<dan@kallistec.com>)
# Copyright:: Copyright (c) 2009 Daniel DeLeo
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

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))

class CouchableObject
  attr_accessor :name
  include Chef::Mixin::Couchable
  extend  Chef::Mixin::Couchable::ClassMethods
  
  def initialize
    @couchdb_rev = "not-a-uuid"
  end
end

describe Chef::Mixin::Couchable do
  
  before do
    @couchable_obj = CouchableObject.new
    @couchable_obj.name = "relaxified"
  end
  
  it "creates a Chef::CouchDB object" do
    @couchable_obj.couchdb.should be_an_instance_of(Chef::CouchDB)
  end
  
  it "has an getter for the couchdb revision" do
    @couchable_obj.couchdb_rev.should == "not-a-uuid"
  end
  
  it "saves itself in couchdb and stores the new revision" do
    @couchable_obj.couchdb.should_receive(:store).
                    with("couchable_object", "relaxified", @couchable_obj).
                    and_return("rev" => "a new revision")
    @couchable_obj.couchdb_save
    @couchable_obj.couchdb_rev.should == "a new revision"
  end
  
  it "destroys its document in couchdb" do
    @couchable_obj.couchdb.should_receive(:delete).with("couchable_object", "relaxified", "not-a-uuid")
    @couchable_obj.couchdb_destroy
  end
  
  describe "extending the class" do
    before do
      CouchableObject.database("couchable_object", "")
    end
    
    after do
      CouchableObject.database(nil,nil)
    end
    
    it "defines a couchdb_doctype as the snake_case of the class name" do
      CouchableObject.couchdb_doctype.should == "couchable_object"
    end
    
    it "creates a Chef::CouchDB object" do
      CouchableObject.couchdb.should be_an_instance_of(Chef::CouchDB)
    end

    it "loads an object by name" do
      CouchableObject.couchdb.should_receive(:load).with("couchable_object", "foo_obj")
      CouchableObject.couchdb_load("foo_obj")
    end
    
    it "lists objects from couchdb (uninflated)" do
      couchdb_response = {"rows" => [{"key" => :key1, "value" => :val1}, {"key" => :key2, "value" => :val2}]}
      CouchableObject.couchdb.should_receive(:list).with("couchable_object", false).and_return(couchdb_response)
      CouchableObject.couchdb_list.should == [:key1, :key2]
    end
    
    it "lists objects from couchdb (inflated)" do
      couchdb_response = {"rows" => [{"key" => :key1, "value" => :val1}, {"key" => :key2, "value" => :val2}]}
      CouchableObject.couchdb.should_receive(:list).with("couchable_object", true).and_return(couchdb_response)
      CouchableObject.couchdb_list(true).should == [:val1, :val2]
    end
    
    it "creates the design document in couch" do
      CouchableObject.database :couchable_items, "a_bunch" => "of_js_and_such"
      CouchableObject.couchdb.should_receive(:create_design_document).with("couchable_items", {"a_bunch" => "of_js_and_such"})
      CouchableObject.create_design_document 
    end
    
    describe "with macros" do
      after do
        CouchableObject.couchdb_doctype :couchable_object
      end
      
      it "lets the couchdb doctype be set manually" do
        CouchableObject.couchdb_doctype :potato_chip
        CouchableObject.couchdb_doctype.should == "potato_chip"
      end
      
      it "lets the design document be specified" do
        design_fragment = {"map" => <<-EOJS
        function(doc) { 
          if (doc.chef_type == "node") {
            emit(doc.name, doc);
          }
        }
        EOJS
        }
        CouchableObject.database :stuff, "map" => <<-EOJS
        function(doc) { 
          if (doc.chef_type == "node") {
            emit(doc.name, doc);
          }
        }
        EOJS
        CouchableObject.design_document.should == design_fragment
        CouchableObject.dbname.should == "stuff"
      end
      
    end
  end
  
end
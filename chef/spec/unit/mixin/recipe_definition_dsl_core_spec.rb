#
# Author:: Daniel DeLeo (<dan@kallistec.om>)
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

class RecipeDSLUser
  include Chef::Mixin::RecipeDefinitionDSLCore
end

class PseudoResource
  
end

describe Chef::Mixin::RecipeDefinitionDSLCore do
  
  before do
    @dsl_user = RecipeDSLUser.new
  end
  
  describe "supplying the basic API required for Recipe DSL use" do
    it "provides a getter cookbook_name" do
      @dsl_user.cookbook_name.should == ""
    end
    
    it "provides a getter for recipe_name" do
      @dsl_user.recipe_name.should == ""
    end
    
    it "provides a getter for collection" do
      @dsl_user.collection.should be_an_instance_of(Chef::ResourceCollection)
    end
    
    it "provides a getter for node" do
      @dsl_user.node.should be_nil
    end
    
    it "provides a getter for cookbook loader" do
      @dsl_user.cookbook_loader.should be_nil
    end
    
    it "provides a getter for params" do
      @dsl_user.params.should == {}
    end
  end
  
  describe "defining DSL sugar methods for resources" do
    
    before do
      @dsl_core = Chef::Mixin::RecipeDefinitionDSLCore
      @implementer = RecipeDSLUser.new
      @implementer.stub!(:node).and_return(:sawks)
    end
    
    it "puts a resource definition prototype in a hash of prototypes" do
      @dsl_core.resource_defn_prototypes.should be_an_instance_of(Hash)
      @dsl_core.resource_defn_prototypes[:whatevs] = :prototype
      @dsl_core.resource_defn_prototypes[:whatevs].should == :prototype
    end
    
    it "defines a method for a resource definition" do
      snitch = nil
      recipe = lambda {snitch = 4815162342}
      defn_clone = mock("cloned resource defn from prototype", :params=> {:tasty=>:cake}, :recipe=>recipe)
      prototype = mock("resource_defn", :new => defn_clone)
      @dsl_core.add_definition_to_dsl(:foobar, prototype)
      @implementer.should respond_to(:foobar)
      defn_clone.should_receive(:node=).with(:sawks)
      @implementer.foobar("baz")
      snitch.should == 4815162342
    end
    
    it "defines a method for a resource" do
      @dsl_core.add_resource_to_dsl(PseudoResource)
      @implementer.should respond_to(:pseudo_resource)
    end

  end
  
end
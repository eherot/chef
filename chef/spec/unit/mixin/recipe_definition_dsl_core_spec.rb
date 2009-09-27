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
    
    it "provides a getter for definitions" do
      @dsl_user.definitions.should == {}
    end
    
    it "provides a getter for cookbook loader" do
      @dsl_user.cookbook_loader.should be_nil
    end
    
    it "provides a getter for params" do
      @dsl_user.params.should == {}
    end
  end
  
end
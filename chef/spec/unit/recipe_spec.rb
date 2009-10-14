#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
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

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe Chef::Recipe do
  before(:each) do
    @node = Chef::Node.new
    @recipe = Chef::Recipe.new("hjk", "test", @node)
    @recipe.stub!(:pp)
    @recipe.node[:tags] = Array.new
  end
 
  describe "from_file" do
    it "should load a resource from a ruby file" do
      @recipe.from_file(File.join(File.dirname(__FILE__), "..", "data", "recipes", "test.rb"))
      res = @recipe.resources(:file => "/etc/nsswitch.conf")
      res.name.should eql("/etc/nsswitch.conf")
      res.action.should eql([:create])
      res.owner.should eql("root")
      res.group.should eql("root")
      res.mode.should eql(0644)
    end
  
    it "should raise an exception if the file cannot be found or read" do
      lambda { @recipe.from_file("/tmp/monkeydiving") }.should raise_error(IOError)
    end
  end
  
  describe "include_recipe" do
    it "should evaluate another recipe with include_recipe" do
      Chef::Config.cookbook_path File.join(File.dirname(__FILE__), "..", "data", "cookbooks")
      @recipe.cookbook_loader.load_cookbooks
      @recipe.include_recipe "openldap::gigantor"
      res = @recipe.resources(:cat => "blanket")
      res.name.should eql("blanket")
      res.pretty_kitty.should eql(false)
    end
  
    it "should load the default recipe for a cookbook if include_recipe is called without a ::" do
      Chef::Config.cookbook_path File.join(File.dirname(__FILE__), "..", "data", "cookbooks")
      @recipe.cookbook_loader.load_cookbooks
      @recipe.include_recipe "openldap"
      res = @recipe.resources(:cat => "blanket")
      res.name.should eql("blanket")
      res.pretty_kitty.should eql(true)
    end
    
    it "should store that it has seen a recipe in node.run_state[:seen_recipes]" do
      Chef::Config.cookbook_path File.join(File.dirname(__FILE__), "..", "data", "cookbooks")
      @recipe.cookbook_loader.load_cookbooks
      @recipe.include_recipe "openldap"
      @node.run_state[:seen_recipes].should have_key("openldap")
    end
    
    it "should not include the same recipe twice" do
      Chef::Config.cookbook_path File.join(File.dirname(__FILE__), "..", "data", "cookbooks")
      @recipe.cookbook_loader.load_cookbooks
      @recipe.include_recipe "openldap"
      Chef::Log.should_receive(:debug).with("I am not loading openldap, because I have already seen it.")
      @recipe.include_recipe "openldap"
    end
  end

  describe "tags" do
    it "should set tags via tag" do
      @recipe.tag "foo"
      @recipe.node[:tags].should include("foo")
    end
  
    it "should set multiple tags via tag" do
      @recipe.tag "foo", "bar"
      @recipe.node[:tags].should include("foo")
      @recipe.node[:tags].should include("bar")
    end
  
    it "should not set the same tag twice via tag" do
      @recipe.tag "foo"
      @recipe.tag "foo"
      @recipe.node[:tags].should eql([ "foo" ])
    end
  
    it "should return the current list of tags from tag with no arguments" do
      @recipe.tag "foo"
      @recipe.tag.should eql([ "foo" ])
    end
  
    it "should return true from tagged? if node is tagged" do
      @recipe.tag "foo"
      @recipe.tagged?("foo").should be(true)
    end
  
    it "should return false from tagged? if node is not tagged" do
      @recipe.tagged?("foo").should be(false)
    end
  
    it "should return false from tagged? if node is not tagged" do
      @recipe.tagged?("foo").should be(false)
    end
  
    it "should remove a tag from the tag list via untag" do
      @recipe.tag "foo"
      @recipe.untag "foo"
      @recipe.node[:tags].should eql([])
    end
  
    it "should remove multiple tags from the tag list via untag" do
      @recipe.tag "foo", "bar"
      @recipe.untag "bar", "foo"
      @recipe.node[:tags].should eql([])
    end
  end
end
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
  
  attr_writer :node
  
end

class PseudoResource
  
end

describe Chef::Mixin::RecipeDefinitionDSLCore do
  R = Chef::Resource
  
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
    
    it "provides a getter for params" do
      @dsl_user.params.should == {}
    end
    
    it "defines a set_enclosing_scope method" do
      lambda {@dsl_user.set_enclosing_scope(nil)}.should_not raise_error
    end
  end
  
  describe "defining DSL sugar methods for resources" do
    
    before do
      @dsl_core = Chef::Mixin::RecipeDefinitionDSLCore
      @implementer = RecipeDSLUser.new
      @implementer.stub!(:node).and_return(:sawks)
    end
    
    it "defines a method for a resource definition" do
      defn_clone = mock("cloned resource defn from prototype", :params=> {:tasty=>:cake}, :recipe=>nil)
      Chef::ResourceDefinition.should_receive(:from_prototype).with(:foobar, :sawks).and_return(defn_clone)
      defn_clone.should_receive(:to_recipe).with("","baz",:sawks,an_instance_of(Chef::ResourceCollection))
      @dsl_core.add_definition_to_dsl(:foobar)
      @implementer.should respond_to(:foobar)
      @implementer.foobar("baz")
    end
    
    it "defines a method for a resource" do
      @dsl_core.add_resource_to_dsl(PseudoResource)
      @implementer.should respond_to(:pseudo_resource)
    end

  end
  
  describe "using the DSL" do
    describe "resources" do
      it "should load a two word (zen_master) resource" do
        lambda do
          @dsl_user.zen_master "monkey" do
            peace true
          end
        end.should_not raise_error(ArgumentError)
      end
  
      it "should load a one word (cat) resource" do
        lambda do
          @dsl_user.cat "loulou" do
            pretty_kitty true
          end
        end.should_not raise_error(ArgumentError)
      end
      
      it "should load a four word (one_two_three_four) resource" do 
        lambda do
          @dsl_user.one_two_three_four "numbers" do
            i_can_count true
          end
        end.should_not raise_error(ArgumentError)
      end
  
      it "should throw an error and log to fatal if you access an undefined resource" do
        Chef::Log.should_receive(:fatal)
        lambda { @dsl_user.not_home { || } }.should raise_error(NameError)
      end
  
      it "should allow regular errors (not NameErrors) to pass unchanged" do
        lambda { 
          @dsl_user.cat { || raise ArgumentError, "You Suck" } 
        }.should raise_error(ArgumentError)
      end
  
      it "should add our zen_master to the collection" do
        @dsl_user.zen_master "monkey" do
          peace true
        end
        @dsl_user.collection.lookup("zen_master[monkey]").name.should eql("monkey")
      end
  
      it "should add our zen masters to the collection in the order they appear" do
        %w{monkey dog cat}.each do |name|
          @dsl_user.zen_master name do
            peace true
          end
        end
        @dsl_user.collection.each_index do |i|
          case i
          when 0
            @dsl_user.collection[i].name.should eql("monkey")
          when 1
            @dsl_user.collection[i].name.should eql("dog")
          when 2
            @dsl_user.collection[i].name.should eql("cat")
          end
        end
      end
        
      it "should return the new resource after creating it" do
        res = @dsl_user.zen_master "makoto" do
          peace true
        end
        res.resource_name.should eql(:zen_master)
        res.name.should eql("makoto")
      end
    end
      
    describe "resource definitions" do
      it "should execute defined resources" do
        crow_define = Chef::ResourceDefinition.new
        crow_define.define :crow, :peace => false, :something => true do
          zen_master "lao tzu" do
            peace params[:peace]
            something params[:something]
          end
        end
        @dsl_user.crow "mine" do
          peace true
        end
        @dsl_user.collection.resources(:zen_master => "lao tzu").name.should eql("lao tzu")
        @dsl_user.collection.resources(:zen_master => "lao tzu").something.should eql(true)
      end

      it "should set the node on defined resources" do
        @dsl_user.node = Chef::Node.new
        
        crow_define = Chef::ResourceDefinition.new
        crow_define.define :crow, :peace => false, :something => true do
          zen_master "lao tzu" do
            peace params[:peace]
            something params[:something]
          end
        end
        @dsl_user.node[:foo] = false
        @dsl_user.crow "mine" do
          something node[:foo]
        end
        @dsl_user.collection.resources(:zen_master => "lao tzu").something.should eql(false)
      end
    end
    
    describe "instance_eval" do
      it "should handle an instance_eval properly" do
        code = <<-CODE
    zen_master "gnome" do
      peace = true
    end
    CODE
        lambda { @dsl_user.instance_eval(code) }.should_not raise_error
        @dsl_user.collection.resources(:zen_master => "gnome").name.should eql("gnome")
      end
    end

  end
  
  describe "being compatible with previous implementations" do
    it "correctly maps method names to all resource classes" do
      @dsl_user.cron("cron").should             be_an_instance_of(R::Cron)
      @dsl_user.deploy("deploy").should         be_an_instance_of(R::Deploy)
      @dsl_user.timestamped_deploy("t").should  be_an_instance_of(R::TimestampedDeploy)
      @dsl_user.deploy_revision("r").should     be_an_instance_of(R::DeployRevision)
      @dsl_user.deploy_branch("b").should       be_an_instance_of(R::DeployBranch)
      @dsl_user.directory("foo").should         be_an_instance_of(R::Directory)
      @dsl_user.execute("bar").should           be_an_instance_of(R::Execute)
      @dsl_user.file("f").should                be_an_instance_of(R::File)
      @dsl_user.group("G").should               be_an_instance_of(R::Group)
      @dsl_user.http_request("H").should        be_an_instance_of(R::HttpRequest)
      @dsl_user.ifconfig("face").should         be_an_instance_of(R::Ifconfig)
      @dsl_user.link("zelda").should            be_an_instance_of(R::Link)
      @dsl_user.mount("equus").should           be_an_instance_of(R::Mount)
      @dsl_user.package("p").should             be_an_instance_of(R::Package)
      @dsl_user.apt_package("A").should         be_an_instance_of(R::AptPackage)
      @dsl_user.dpkg_package("d").should        be_an_instance_of(R::DpkgPackage)
      #weird, no such thing as freebsd_package
      #@dsl_user.freebsd_package("bh").should    be_an_instance_of(R::FreebsdPackage)
      @dsl_user.portage_package("Porty").should be_an_instance_of(R::PortagePackage)
      @dsl_user.gem_package("gemmmm").should    be_an_instance_of(R::GemPackage)
      # also weird, also no such thing
      #@dsl_user.yum_package("Nom").should       be_an_instance_of(R::YumPackage)
      @dsl_user.remote_directory("Rd").should   be_an_instance_of(R::RemoteDirectory)
      @dsl_user.remote_file("RF").should        be_an_instance_of(R::RemoteFile)
      @dsl_user.route("arrr").should            be_an_instance_of(R::Route)
      @dsl_user.ruby_block("bloxor").should     be_an_instance_of(R::RubyBlock)
      @dsl_user.scm("not p4").should            be_an_instance_of(R::Scm)
      @dsl_user.git("yeah").should              be_an_instance_of(R::Git)
      @dsl_user.subversion("is slow").should    be_an_instance_of(R::Subversion)
      @dsl_user.script("s").should              be_an_instance_of(R::Script)
      @dsl_user.bash("thrash").should           be_an_instance_of(R::Bash)
      @dsl_user.csh("dsh").should               be_an_instance_of(R::Csh)
      @dsl_user.perl("isn't peridot").should    be_an_instance_of(R::Perl)
      @dsl_user.python("snakey").should         be_an_instance_of(R::Python)
      @dsl_user.ruby("duby|dubious").should     be_an_instance_of(R::Ruby)
      @dsl_user.service("with frown").should    be_an_instance_of(R::Service)
      @dsl_user.template("ezrubious").should    be_an_instance_of(R::Template)
      @dsl_user.user("not loser").should        be_an_instance_of(R::User)
    end
    
  end
  
end
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

require 'chef/mixin/check_helper.rb'
require 'chef/mixin/checksum.rb'
require 'chef/mixin/command.rb'
require 'chef/mixin/convert_to_class_name.rb'
require 'chef/mixin/create_path.rb'
require 'chef/mixin/deep_merge.rb'
require 'chef/mixin/find_preferred_file.rb'
require 'chef/mixin/from_file.rb'
require 'chef/mixin/generate_url.rb'
require 'chef/mixin/language.rb'
require 'chef/mixin/language_include_attribute.rb'
require 'chef/mixin/language_include_recipe.rb'
require 'chef/mixin/params_validate.rb'
require 'chef/mixin/recipe_definition_dsl_core.rb'
require 'chef/mixin/template.rb'

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

require "chef/mixin/convert_to_class_name"

class Chef
  module Mixin
    module Couchable
      attr_reader :couchdb_rev
      
      def couchdb_doctype
        self.class.couchdb_doctype
      end
      
      def couchdb
        self.class.couchdb
      end
      
      def couchdb_save
        @couchdb_rev = couchdb.store(couchdb_doctype, name, self)["rev"]
      end
      alias :cdb_save :couchdb_save
      
      def couchdb_destroy
        couchdb.delete(couchdb_doctype, name, couchdb_rev)
      end
      alias :cdb_destroy :couchdb_destroy
      
      module ClassMethods
        attr_reader :dbname, :design_document
        
        def couchdb_doctype(doctype=nil)
          @couchdb_doctype = doctype.to_s if doctype
          @couchdb_doctype ||= ConvertToClassName.convert_to_snake_case(self.name.split("::").last)
        end
        
        def couchdb
          @couchdb ||= Chef::CouchDB.new
        end
        
        def database(dbname, document)
          @dbname, @design_document = dbname.to_s, document
        end
        
        def create_design_document
          couchdb.create_design_document(@dbname, @design_document)
        end
        
        def couchdb_load(name)
          couchdb.load(couchdb_doctype, name)
        end
        alias :cdb_load :couchdb_load
        
        def couchdb_list(inflate=false)
          map_on = inflate ? "value" : "key"
          couchdb.list(couchdb_doctype, inflate)["rows"].map { |row| row[map_on] }
        end
        alias :cdb_list :couchdb_list
        
      end
      
    end
  end
end
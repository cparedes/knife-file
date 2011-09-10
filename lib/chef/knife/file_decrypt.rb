#
# Author:: Christian Paredes <cp@redbluemagenta.com>
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

class Chef
  class Knife
    class FileDecrypt < Knife

      deps do
        require 'chef/json_compat'
        require 'chef/encrypted_data_bag_item'
        require 'chef/knife/core/object_loader'
      end

      banner "knife file decrypt FILE [options]"

      option :secret,
      :short => "-s SECRET",
      :long  => "--secret ",
      :description => "The secret key to use to decrypt data bag item values",
      :proc => Proc.new { |key| Chef::Config[:knife][:secret] = key }

      option :secret_file,
      :long => "--secret-file SECRET_FILE",
      :description => "A file containing the secret key to use to decrypt data bag item values",
      :proc => Proc.new { |key| Chef::Config[:knife][:secret_file] = key }

      def read_secret
        if Chef::Config[:knife][:secret]
            Chef::Config[:knife][:secret]
        else
            Chef::EncryptedDataBagItem.load_secret(Chef::Config[:knife][:secret_file])
        end
      end

      def decrypt(plain_hash, secret)
        plain_hash.inject({}) do |h, (key, val)|
            h[key] = if key != "id"
                           Chef::EncryptedDataBagItem.decrypt_value(val, secret)
                         else
                           val
                         end
            h
        end
      end

      def use_encryption
        if Chef::Config[:knife][:secret] && Chef::Config[:knife][:secret_file]
            stdout.puts "please specify only one of --secret, --secret-file"
            exit(1)
        end
        Chef::Config[:knife][:secret] || Chef::Config[:knife][:secret_file]
      end

      def loader
        @loader ||= Chef::Knife::Core::ObjectLoader.new(Chef::DataBagItem, ui)
      end

      def run
        if @name_args.size != 1
            stdout.puts opt_parser
            exit(1)
        end
        @item_path = @name_args[0]
        if ! use_encryption
            stdout.puts opt_parser
            exit(1)
        end
        secret = read_secret
        item = loader.object_from_file(@item_path)
        item = decrypt(item, secret)
        output(format_for_display(item.to_hash))
      end
    end
  end
end

class Chef
  class Knife
    class FileEdit < Knife

      deps do
        require 'chef/json_compat'
        require 'chef/encrypted_data_bag_item'
        require 'chef/knife/core/object_loader'
      end

      banner "knife file edit FILE [options]"

      option :secret,
      :short => "-s SECRET",
      :long => "--secret ",
      :description => "The secret key to use to decrypt/encrypt data bag item values"

      option :secret_file,
      :long => "--secret-file SECRET_FILE ",
      :description => "A file containing the secret key to use to decrypt/encrypt data bag item values"

      def read_secret
        if config[:secret]
          config[:secret]
        else
          Chef::EncryptedDataBagItem.load_secret(config[:secret_file])
        end
      end

      def use_encryption
        if config[:secret] && config[:secret_file]
            stdout.puts "please specify only one of --secret, --secret-file"
            exit(1)
        end
        config[:secret] || config[:secret_file]
      end

      def loader
        @loader ||= Chef::Knife::Core::ObjectLoader.new(Chef::DataBagItem, ui)
      end
      
      def load_file(file_path)
        item = loader.object_from_file(file_path)
        if use_encryption
          Chef::EncryptedDataBagItem.new(item, read_secret).to_hash
        else
          item
        end
      end

      def edit_item(item)
        output = edit_hash(item)
        if use_encryption
          Chef::EncryptedDataBagItem.encrypt_data_bag_item(output, read_secret).to_hash
        else
          output
        end
      end

      def run
        if @name_args.length != 1
          stdout.puts "You must supply a file to edit!"
          stdout.puts opt_parser
          exit 1
        end
        item = load_file(@name_args[0])
        output = edit_item(item)
        f = File.open(@name_args[0], "w")
        f.sync = true
        f.puts JSONCompat::to_json_pretty(output)
        f.close
        stdout.puts("Saved data_bag_item[#{@name_args[0]}]")
        output(format_for_display(object.raw_data)) if config[:print_after]
      end
    end
  end
end      
      

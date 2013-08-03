class Zone < ActiveRecord::Base
    has_many :records

    validates_uniqueness_of :name



    def nsupdate!
	IO.popen('nsupdate', 'w') do |io|
            io.puts "server #{master}"
            io.puts "zone #{name}"
            # TODO track the key name and key
            io.puts "key dns_cp-key #{key}"

            deleted_records.each do |rr|
                io.puts "update delete #{rr}"
            end

            added_records.each do |rr|
                io.puts "update add #{rr}"
            end

            # Display our pending update
            io.puts "show"
            # Send it
            io.puts "send"
            io.puts "answer"
        end
        # Wipe our cached records
        @records = nil
        @original_records = nil
    end

    def added_records
        @records - @original_records
    end

    def deleted_records
        @original_records - @records
    end

    def fetch_records
        res = Net::DNS::Resolver.new(:nameservers => (master || "localhost"))

        response = res.axfr(self.name)

        response.answer.map{|rr| self.records.new(:rr => rr)}
    end
end
module Net
  module DNS
    class RR
      extend ActiveModel::Naming
      include ActiveModel::Conversion

      attr_accessor :id

      def persisted?
          false
      end
      #------------------------------------------------------------
      # RR type SSHFP
      #------------------------------------------------------------
      class SSHFP < RR
        attr_reader :algorithm, :fp_type, :fingerprint

        private
        
        def check_sshfp(str)
          if str.strip =~ /^(\d)\s+(\d)\s+([0-9a-fA-F]+)$/
            return $1,$2,$3
          else
            raise ArgumentError, "SSHFP section not valid: #{str.inspect}"
          end
        end
        
        def build_pack
          @sshfp_pack = [@algorithm].pack("n")
          @sshfp_pack += [@fp_type].pack("n")
          @sshfp_pack += @fingerprint
          @rdlength = @sshfp_pack.size
        end

        def get_data
          @sshfp_pack
        end

        def get_inspect
          "#@algorithm #@fp_type #@fingerprint"
        end

        def subclass_new_from_hash(args)
          if args.has_key? :cpu and args.has_key? :os
            @cpu = args[:cpu]
            @os =  args[:os]
          else
            raise ArgumentError, ":cpu and :os fields are mandatory but missing"
          end
        end

        def subclass_new_from_string(str)
          @cpu,@os = check_sshfp(str)
        end

        def subclass_new_from_binary(data,offset)
          len = data.unpack("@#{offset} C")[0]
          @cpu = data[offset+1..offset+1+len]
          offset += len+1
          len = @data.unpack("@#{offset} C")[0]
          @os = data[offset+1..offset+1+len]
          return offset += len+1
        end
        
        private
        
          def set_type
            @type = Net::DNS::RR::Types.new("SSHFP")
          end
        
      end # class SSHFP
      
    end # class RR
  end # module DNS
end # module Net


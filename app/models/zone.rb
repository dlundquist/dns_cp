class Zone < ActiveRecord::Base
    validates_uniqueness_of :name

    def records
        res = Net::DNS::Resolver.new(:nameservers => (master || "localhost"))

        response = res.axfr(self.name)

        response.answer.each { |i| i.class_eval("extend ActiveModel::Naming") } 
    end

    def nsupdate!
	IO.popen('nsupdate', 'w') do |io|
            io.puts "server #{master}"
            io.puts "zone #{name}"
            io.puts "key dns_cp-key #{key}"

            # TODO add or remove records here

            # Display our pending update
            io.puts "show"
            # Send it
            io.puts "send"
            io.puts "answer"
        end
    end
end

class ::Net::DNS::RR
    extend ActiveModel::Naming
end

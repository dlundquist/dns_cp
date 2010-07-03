class Zone < ActiveRecord::Base
    validates_uniqueness_of :name

    def records
        res = Net::DNS::Resolver.new(:nameservers => (master || "localhost"))

        response = res.axfr(self.name)

        response.answer
    end
end

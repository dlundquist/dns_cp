class Zone < ActiveRecord::Base
  validates_uniqueness_of :name

  require 'net/dns/resolver'

  def records
    res = Net::DNS::Resolver.new(:nameservers => "127.0.0.1")

    response = res.axfr(self.name)

    response.answer
  end
end

class Record < ActiveRecord::Base
	belongs_to :zone

	composed_of :rr,
            :class_name => 'Net::DNS::RR',
            :mapping => [ %w(name name), %w(ttl ttl), %w(type rtype), %w(cls cls), %w(rdata rdata) ]

end

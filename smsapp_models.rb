require 'rubygems'
require 'activerecord'
require 'gupshup'
require 'logger'
require 'open-uri'

ActiveRecord::Base.establish_connection(
    :adapter  => "mysql",
    :host     => "localhost",
    :username => "root",
    :password => "",
    :database => "gupshupapps"
)

class Smsapp < ActiveRecord::Base
  has_many :masks
  has_many :keywords
  has_many :kvpairs
  App_Logger = Logger.new(STDOUT)

  def store_kvpair(key, val, phone = nil)
    number = (phone.nil? ? -1 : phone.number)
    unless (fk = self.kvpairs.find_by_phone_and_fkey(number,key))
      fk = self.kvpairs.build({ :fkey => key, :phone => number })
    end
    fk.fvalue = val
    fk.save
  end

  def fetch_kvpair(key, phone = nil)
    number = (phone.nil? ? -1 : phone.number)
    fk = self.kvpairs.find_by_phone_and_fkey(number, key)
    fk.fvalue unless fk.nil?
  end

  def increment_kvpair(key, phone = nil)
    v = fetch_kvpair(key, phone)
    if v.nil?
      store_kvpair(key, "1", phone)
    else
      i = v.to_i
      store_kvpair(key, (i+1).to_s, phone)
    end
  end

  def data_for(phone)
    self.kvpairs.find_all_by_phone(phone.number)
  end

  def send_message(phone, message, mask = nil)
    if self.gupshup_login.nil?
      gup = Gupshup::Enterprise.new(2000021944, 'kaddy')
    else
      gup = Gupshup::Enterprise.new(self.gupshup_login, self.gupshup_password)
    end
    gup.send_text_message(message, phone.number)
  end

  def scrape(url)
    result = open(url)
    text = result.read
  end
end

class Mask < ActiveRecord::Base
  belongs_to :smsapp
end

class Keyword < ActiveRecord::Base
  belongs_to :smsapp
#  belongs_to :longcode
end

class Kvpair < ActiveRecord::Base
  belongs_to :smsapp
end

class Phone
  def initialize(number)
    n = number.to_i
    if n >= 8000000000 && n <= 9999999999
      n += 910000000000
    elsif n >= 918000000000 && n <= 919999999999
      # do nothing
    else
      n = 0
    end
    @number = n
  end

  def number
    @number
  end

  def invalid?
    @number == 0
  end
end


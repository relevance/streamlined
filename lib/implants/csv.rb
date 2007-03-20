require 'csv'

module Enumerable
  def to_csv(keys, options = {:header=>true})
    str = ''
    header = options.delete(:header)
    header = keys if header == true
    ::CSV::Writer.generate(str) do |csv|
      csv << header if header
      each do |item|
        csv << keys.inject([]) {|coll,key| coll << item.send(key); coll}
      end
    end 
    str
  end
end
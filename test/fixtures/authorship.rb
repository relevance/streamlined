class Authorship < ActiveRecord::Base
  belongs_to :author
  belongs_to :publication, :polymorphic => true
  belongs_to :article,  :class_name => "Article",
                        :foreign_key => "publication_id"
  belongs_to :book,     :class_name => "Book",
                        :foreign_key => "publication_id"
end

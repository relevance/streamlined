class PersonUI < Streamlined::UI
end

module PersonAdditions
  def full_name
    "#{first_name} #{last_name}"
  end
end

Person.class_eval {include PersonAdditions}
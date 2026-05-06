# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#  admin      :boolean          default(FALSE)
#  guest      :boolean          default(FALSE)
#  locale     :string           default("en-US")
#  name       :string
#  gender     :string
#  mugshot    :string
#  link       :string
#
class User < ApplicationRecord

  def to_s
    name
  end

end

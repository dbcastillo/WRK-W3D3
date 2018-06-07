# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint(8)        not null, primary key
#  long_url   :string           not null
#  short_url  :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedUrl < ApplicationRecord

  def self.random_code
    loop do
      code = SecureRandom.urlsafe_base64
      return code if !ShortenedUrl.where(short_url: code).exists?
    end
  end

  def self.make_shorter(user, long)
    ShortenedUrl.create!(long_url: long, user_id: user.id, short_url: ShortenedUrl.random_code)
  end

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: "User"

  has_many :visits,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: "Visit"

  has_many :visitors,
    through: :visits,
    source: :visitor

  def num_clicks
    self.visitors.count
  end

  def num_uniques
    # self.visitors.uniq.count
    count = ApplicationRecord.connection.execute(<<-SQL, self.id)
      SELECT
        COUNT(DISTINCT user_id)
      FROM
        visits
      WHERE
        visits.url_id = ?
    SQL

    count.first["count"]
  end

  def num_recent_uniques

  end


end

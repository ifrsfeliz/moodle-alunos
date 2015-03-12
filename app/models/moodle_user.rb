class MoodleUser < ActiveRecord::Base
  establish_connection :moodle

  def self.all
    connection.select_all('SELECT * FROM mdl_user u ORDER BY u.firstname ASC')
  end

  def self.all_categories
    connection.select_all('SELECT * FROM mdl_course_categories ORDER BY sortorder')
  end

  def self.students_by_category(path)
    @students = connection.select_all("
      SELECT u.username, u.firstname, u.lastname, u.email, u.city, u.country
      FROM mdl_role_assignments AS ra
      JOIN mdl_context AS context ON context.id = ra.contextid AND context.contextlevel = 50
      JOIN mdl_course AS c ON c.id = context.instanceid
      JOIN mdl_course_categories AS cc ON cc.id = c.category
      JOIN mdl_user AS u ON u.id = ra.userid
      WHERE ra.roleid = 5 AND cc.path LIKE '#{path}%'
      GROUP BY u.email
      ORDER BY u.firstname")
  end

end

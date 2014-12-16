# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'yaml'

class Backup

  attr_accessor :time, :application_file, :database_file, :comment

  def initialize(time, application_file, database_file, comment = nil)
    self.time = time
    self.application_file = application_file
    self.database_file = database_file
    self.comment = comment
  end

  def human_readable_time
    DateTime.parse(self.time).strftime("%m-%d-%Y %H:%M:%S")
  end
end

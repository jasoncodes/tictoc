require 'bundler'
Bundler.setup

require 'active_support/core_ext'
require 'appscript'
require 'active_record'
require 'sqlite3'

class Tictoc
  def self.running?
    Appscript.app('System Events').processes[Appscript.its.name.eq('Tictoc')].get.present?
  end

  def self.start
    Appscript.app('Tictoc').run
  end

  def self.stop
    Appscript.app('Tictoc').quit if running?
  end
end

was_running = Tictoc.running?
Tictoc.stop
at_exit do
  Tictoc.start if was_running
end

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => File.expand_path('~/Library/Application Support/Tictoc/Tictoc.sqlite')

class TictocModel < ActiveRecord::Base
  self.abstract_class = true
  set_primary_key 'Z_PK'

  def self.cocoa_time_field(name, source_field)
    define_method name do
      Time.utc(2001,1,1,0,0,0) + send(source_field)
    end
  end
end

class Session < TictocModel
  set_table_name 'ZTCSESSION'
  belongs_to :task, :foreign_key => 'ZTASK'

  cocoa_time_field :time_started, :ZSTARTEDAT
  cocoa_time_field :time_stopped, :ZENDEDAT

  def duration
    time_stopped - time_started
  end

  def local_date
    time_started.getlocal.to_date
  end
end

class Task < TictocModel
  set_table_name 'ZTCTASK'
  has_many :sessions, :foreign_key => 'ZTASK'

  alias_attribute :name, :ZNAME
end

footer_text = "Total:"
days = {}
max_name_len = footer_text.size
Session.includes(:task).sort_by do |session|
  [session.local_date, session.task.name.downcase]
end.each do |session|
  day = days[session.local_date] ||= Hash.new(0)
  day[session.task.name] += session.duration / 3600.0
  max_name_len = [max_name_len, session.task.name.size].max
end

def format_hours(hours)
  "#{hours.floor.to_s.rjust 2}:#{(hours*60%60).round(0).to_s.rjust(2,'0')} (#{hours.round(2)} hours)"
end

days.each do |date,tasks|
  puts date.strftime '%Y-%m-%d %A'
  tasks.each do |name, hours|
    puts "  #{name.ljust max_name_len} #{format_hours hours}"
  end
  puts "  #{footer_text.rjust max_name_len} #{format_hours tasks.values.sum}"
  puts
end

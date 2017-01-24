#!/usr/bin/env ruby
require 'date'
require 'fileutils'

TIMETABLE_PATH='~/timetable'
NOTES_DIR='~/notes/'

# Return a command to execute when the notes file has been executed.
def get_command(path)
  #"gnome-terminal -e \"vim -c 'normal GA' #{path}\""
  "gvim -c 'normal GA' #{path}"
end

# Turn an event name (eg. "Doing This and That") into an initialism
# which rejects any words of three or less characters (eg. "DTT" in
# this case)
def initialism(s)
  return s
    .strip
    .gsub(/[^A-Za-z]/, ' ')
    .gsub(/ +/, ' ')
    .split(' ')
    .reject {|w| w.length < 4}
    .map {|w| w[0]}
    .join ''
end

# Reads the timetable stored in the given file into a hash of days
# to hashes of hours to event names. For example, to get the name
# of the event at 2pm on Thursday, you might do this:
#
# Configuration keys stored in 'config' item
#
# timetable = read_timetable('timetable')
# event_at_2pm_thurs = timetable['thu'][14]
def read_timetable(filename)
  config = {}
  h = Hash[File.readlines(filename).map do |line|
    # Split the line at the colon to get the day and the content
    if line.start_with? '#'
      nil # ignore
    elsif line.start_with? '%'
      name, value = line[1..-1].chomp.split('=', 2)
      config[name] = value
      nil
    else
      day_of_week, event_string = *line
        .chomp
        .split(':')
        .map(&:strip)
      day_of_week.downcase!

      events = Hash[event_string
        .split(',')
        .map do |event|
          # For each event on this day, get the name and time string
          # Where an event spanning multiple hours (eg. at both 9 and
          # 10 am can be given as "@9+10")
          name, time_string = *event
            .split('@')
            .map(&:strip)
          time_string
            .split('+')
            .map(&:to_i)
            .map {|hour| [hour, name]}
        end.flatten(1)]
      [day_of_week, events]
    end
  end.reject(&:nil?)]
  h['config'] = config
  h
end

now = DateTime.now

if $1 == "-s"
  # If the script is called with the -s flag, use the next parameter
  # as the event name and skip looking at the timetable
  event_name = $2
  event_initialism = initialism(event_name)
else
  weekday = now.strftime("%a").downcase
  hour = now.hour
  timetable = read_timetable(File.expand_path(TIMETABLE_PATH))
  event_day = timetable[weekday]
  if event_day
    event_name = event_day[hour]
  end
  if event_name
    event_initialism = timetable['config']["init(#{event_name})"] || initialism(event_name)
  else
    event_name = "Etcetera"
    event_initialism = "Etc"
  end
end

date = now.strftime('%F-%a')
dir = File.expand_path "#{NOTES_DIR}#{event_initialism.downcase}"
FileUtils.mkpath dir
path = "#{dir}/#{date.downcase}.md"

file_exists = File.exist? path
File.open(path, 'a') do |file|
  if file_exists
    puts "Opening existing notes for #{event_name} on #{date}."
    file.write("\n\n")
  else
    puts "Creating new notes file for #{event_name} on #{date}."
    
    # If it's a new file, add the event name and the date to the top of the file
    file.write("# #{event_name} on #{now.strftime('%A %-d %B %Y')}\n")
  end

  # Append the specific hour to the file (eg. if we edit the same file multiple
  # times if you have the same event at several points during the day)
  file.write("## #{now.strftime('%-I%P')}: ")
end

exec get_command(path)

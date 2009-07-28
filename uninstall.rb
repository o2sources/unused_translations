require 'fileutils'

# Delete the script 'unused_translations.rb'

script_dir = File.dirname(__FILE__) + '/../../../script'
unused_translations_script = script_dir + '/unused_translations'

FileUtils.rm unused_translations_script

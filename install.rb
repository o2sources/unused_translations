require 'fileutils'

# Install the script 'unused_translations.rb'

script_dir = File.dirname(__FILE__) + '/../../../script'
unused_translations_script = script_dir + '/unused_translations'

FileUtils.cp File.dirname(__FILE__) + '/script/unused_translations', unused_translations_script unless File.exists?(unused_translations_script)

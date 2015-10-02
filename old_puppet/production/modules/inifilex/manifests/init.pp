# This module is a homemade extension of the puppetlabs-inifile
# module and provides the inifilex::settings resource.
#
# == Requirement/Dependencies
#
# Depends on:
#   - Puppetlabs-stdlib module,
#   - homemade_functions module,
#   - and puppetlabs-inifile module.
#
# == Parameters
#
# *path*:
# The path of the ini file to modify. This parameter is
# optional and the default value is the title of the
# resource.
#
# *settings*:
# This parameter is mandatory and must be a hash like this:
#
#  $settings = {
#                'section_a' => {
#                                 'entry_a1' => 'value_a1',
#                                 'entry_a2' => 'value_a2',
#                },
#                'section_b' => {
#                                 'entry_b1' => 'value_b1',
#                                 'entry_b2' => 'value_b2',
#                                 'entry_b3' => undef,
#                },
#  }
#
# If a value is undef, the entry will be remove in the
# ini file. In hiera, you must use the null value to
# remove an entry. Otherwise, all values must be strings.
#
# == Sample Usages
#
#  # $setting is defined as above.
#
#  inifilex::settings { 'edit-foo.ini':
#    path     => '/tmp/foo.ini':
#    settings => $settings,
#  }
#
#
define inifilex::settings (
  $path = $title,
  $settings,
) {

  $hash_settings = str2hash(inline_template('
    <%-
      c = 0
      title = @title
      error_msg = "ini_settings `#{title}` error: `settings` parameter must "
      error_msg += "be a hash where the keys are strings and values are "
      error_msg += "hashes of strings values or undef."
      hash_settings = {}
      @settings.each do |section, entries|
        unless section.is_a?(String) and entries.is_a?(Hash)
          fail(error_msg)
        end
        entries.each do |entry, value|
          unless entry.is_a?(String)
            fail(error_msg)
          end
          c += 1
          subtitle = @title + "_#{c}"
          hash_settings[subtitle] = {
            "path"    => @path,
            "section" => section,
            "setting" => entry,
            "value"   => value,
          }
          # If the value is defined to undef in puppet => equal to :undef
          # If the value is defined to null in hiera   => equal to nil
          if value == :undef or value == nil
            hash_settings[subtitle]["ensure"] = "absent"
          else
            unless value.is_a?(String)
              fail(error_msg)
            end
            hash_settings[subtitle]["ensure"] = "present"
            hash_settings[subtitle]["value"] = value
          end
        end
      end
    -%>
    <%= hash_settings.to_s %>
  '))

  create_resources('ini_setting', $hash_settings)

}


